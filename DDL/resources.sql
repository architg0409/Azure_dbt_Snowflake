CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV' 
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


    


CREATE STORAGE INTEGRATION azure_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = '<tenant-id>'
  STORAGE_ALLOWED_LOCATIONS = ('azure://<storage_account>.blob.core.windows.net/<container>/');

  DESC STORAGE INTEGRATION azure_int;




CREATE STAGE snowstage
  URL = 'azure://<storage_account>.blob.core.windows.net/<container>/'
  STORAGE_INTEGRATION = azure_int
  FILE_FORMAT = csv_format;


  LIST @snowstage;

  show stages;

  show file formats;


COPY INTO BOOKINGS
FROM @snowstage
FILES=('bookings.csv')
FILE_FORMAT = (FORMAT_NAME = csv_format);


COPY INTO LISTINGS
FROM @snowstage
FILES=('listings.csv')
FILE_FORMAT = (FORMAT_NAME = csv_format);


COPY INTO HOSTS
FROM @snowstage
FILES=('hosts.csv')
FILE_FORMAT = (FORMAT_NAME = csv_format);