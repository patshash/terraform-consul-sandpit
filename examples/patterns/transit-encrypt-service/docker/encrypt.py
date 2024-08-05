import os
import requests
import boto3
import json
import base64
import logging
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def generate_data_key(VAULT_ADDR, VAULT_TOKEN, VAULT_NAMESPACE, VAULT_KEY_NAME):
    """ Generate plaintext data key from Vault Transit Secrets Engine. """
    url = f"{VAULT_ADDR}/v1/transit/datakey/plaintext/{VAULT_KEY_NAME}"
    headers = {
        'X-Vault-Token': VAULT_TOKEN,
        'X-Vault-Namespace': VAULT_NAMESPACE,
        'Content-Type': 'application/json'
    }
    response = requests.post(url, headers=headers, verify=True)  # verify=false to ignore SSL certificate validation
    if response.status_code == 200:
        logger.info("Successfully generated Vault plaintext data key")
    else:
        logger.error(f"Failed to generate Vault plaintext data key: {response.text}")
    return response.json()

def encrypt_data(plaintext_data, key):
    """ Encrypt data using generated plaintext data key. """
    try:
        key_bytes = base64.b64decode(key)
        iv = b'\x00' * 12  # initialization vector
        encryptor = Cipher(algorithms.AES(key_bytes), modes.GCM(iv), backend=default_backend()).encryptor()
        encrypted_data = encryptor.update(plaintext_data) + encryptor.finalize()
        logger.info("Successfully encrypted data")
        return encrypted_data, base64.b64encode(encryptor.tag).decode()
    except Exception as e:
        logger.error(f"Failed to encrypt data: {str(e)}")
        raise

def download_file_from_s3(S3_BUCKET_NAME, S3_UNENCRYPTED_FILE_PATH, LOCAL_UNENCRYPTED_FILE_PATH):
    """ Download file from S3. """
    s3 = boto3.client('s3')
    try:
        s3.download_file(S3_BUCKET_NAME, S3_UNENCRYPTED_FILE_PATH, LOCAL_UNENCRYPTED_FILE_PATH)
        logger.info(f"Successfully downloaded file from S3 {S3_UNENCRYPTED_FILE_PATH}")
    except ClientError as e:
        logger.error(f"Failed to download file from S3: {e}")
        if e.response['Error']['Code'] == '404':
            logger.error(f"The object does not exist: {e}")
        else:
            raise

def save_encrypted_data(encrypted_data, filepath):
    """ Save encrypted data. """
    try:
        with open(filepath, 'wb') as file:
            file.write(encrypted_data)
        logger.info("Successfully saved encrypted data")
    except Exception as e:
        logger.error(f"Failed to save encrypted data: {str(e)}")
        raise

def create_meta_data(tag, ciphertext_key, filepath):
    """ Create metadata for the encrypted data. """
    try:
        with open(filepath, 'w') as file:
            json.dump({'tag': tag, 'ciphertext_key': ciphertext_key}, file, indent=4)
        logger.info("Successfully created metadata file")
    except Exception as e:
        logger.error(f"Failed to create metadata file: {str(e)}")
        raise

def upload_encrypted_file_to_s3(S3_BUCKET_NAME, S3_ENCRYPTED_FILE_PATH, LOCAL_ENCRYPTED_FILE_PATH):
    """ Upload encrypted data to S3. """
    s3 = boto3.client('s3')
    try:
        s3.upload_file(LOCAL_ENCRYPTED_FILE_PATH, S3_BUCKET_NAME, S3_ENCRYPTED_FILE_PATH)
        logger.info("Successfully uploaded encrypted data to S3.")
    except ClientError as e:
        logger.error(f"Failed to upload encrypted data to S3: {e}")
        raise

def upload_meta_file_to_s3(S3_BUCKET_NAME, S3_ENCRYPTED_META_FILE_PATH, LOCAL_ENCRYPTED_META_FILE_PATH):
    """ Upload metadata file to S3. """
    s3 = boto3.client('s3')
    try:
        s3.upload_file(LOCAL_ENCRYPTED_META_FILE_PATH, S3_BUCKET_NAME, S3_ENCRYPTED_META_FILE_PATH)
        logger.info("Successfully uploaded metadata file to S3.")
    except ClientError as e:
        logger.error(f"Failed to upload metadata file to S3: {e}")
        raise

# set variables
VAULT_ADDR = os.getenv('VAULT_ADDR')
VAULT_TOKEN = os.getenv('VAULT_TOKEN')
VAULT_NAMESPACE = os.getenv('VAULT_NAMESPACE')
VAULT_KEY_NAME = os.getenv('VAULT_KEY_NAME')
LOCAL_UNENCRYPTED_FILE_PATH = 'unencrypted.data' #filepath to save the unencrypted file
LOCAL_ENCRYPTED_FILE_PATH = 'encrypted.data'  # filepath to save the encrypted file
LOCAL_ENCRYPTED_META_FILE_PATH = 'encrypted.meta' # filepath to save the encrypted metadata file
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
S3_UNENCRYPTED_FILE_PATH = os.getenv('S3_UNENCRYPTED_FILE_PATH')
S3_ENCRYPTED_FILE_PATH = f'{VAULT_KEY_NAME}/{LOCAL_ENCRYPTED_FILE_PATH}'
S3_ENCRYPTED_META_FILE_PATH = f'{VAULT_KEY_NAME}/{LOCAL_ENCRYPTED_META_FILE_PATH}'

# log environment information
logger.info(f'Vault Address: {VAULT_ADDR}')
logger.info(f'Vault Namespace: {VAULT_NAMESPACE}')
logger.info(f'Vault Key Name: {VAULT_KEY_NAME}')
logger.info(f'S3 Bucket Name: {S3_BUCKET_NAME}')
logger.info(f'S3 Unencrypted File Path: {S3_UNENCRYPTED_FILE_PATH}')
logger.info(f'S3 Encrypted File Path: {S3_ENCRYPTED_FILE_PATH}')
logger.info(f'S3 Encrypted Meta File Path: {S3_ENCRYPTED_META_FILE_PATH}')

# main logic
datakey_response = generate_data_key(VAULT_ADDR, VAULT_TOKEN, VAULT_NAMESPACE, VAULT_KEY_NAME)
if 'data' in datakey_response:
    plaintext_key = datakey_response['data']['plaintext']
    ciphertext_key = datakey_response['data']['ciphertext']

    # download and load data
    download_file_from_s3(S3_BUCKET_NAME, S3_UNENCRYPTED_FILE_PATH, LOCAL_UNENCRYPTED_FILE_PATH)
    data = open(LOCAL_UNENCRYPTED_FILE_PATH, 'rb')
    if data.mode == 'rb':
        unencrypted_data = data.read()

    # encrypt data using the plaintext data key
    encrypted_data, tag = encrypt_data(unencrypted_data, plaintext_key)

    # save encrypted data
    save_encrypted_data(encrypted_data, LOCAL_ENCRYPTED_FILE_PATH)
    logger.info("Encrypted data has been saved to 'encrypted_data'")

    # save metadata file
    create_meta_data(tag, ciphertext_key, LOCAL_ENCRYPTED_META_FILE_PATH)
    logger.info("Metadata has been saved to 'encrypted_data.meta'")

    # upload encrypted data to S3
    upload_encrypted_file_to_s3(S3_BUCKET_NAME, S3_ENCRYPTED_FILE_PATH, LOCAL_ENCRYPTED_FILE_PATH)

    # upload metadata file to S3
    upload_meta_file_to_s3(S3_BUCKET_NAME, S3_ENCRYPTED_META_FILE_PATH, LOCAL_ENCRYPTED_META_FILE_PATH)

else:
    logger.error("Error generating plaintext data key: %s", datakey_response.get('errors', 'Unknown error'))