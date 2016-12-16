<?php
return array (
  'backend' =>
  array (
    'frontName' => 'admin',
  ),
  'crypt' =>
  array (
    'key' => '848973ffa15fee5248ce5cfcfe9fbdb4',
  ),
  'session' =>
  array (
 'session' =>
  array (
   'save' => 'redis',
   'redis' => 
      array (
	'host' => '127.0.0.1',
	'port' => '6379',
	'password' => '',
	'timeout' => '2.5',
	'persistent_identifier' => '',
	'database' => '0',
	'compression_threshold' => '2048',
	'compression_library' => 'gzip',
	'log_level' => '1',
	'max_concurrency' => '6',
	'break_after_frontend' => '5',
	'break_after_adminhtml' => '30',
	'first_lifetime' => '600',
	'bot_first_lifetime' => '60',
	'bot_lifetime' => '7200',
	'disable_locking' => '0',
	'min_lifetime' => '60',
	'max_lifetime' => '2592000'
    )
  ),
  'db' =>
  array (
    'table_prefix' => '',
    'connection' =>
    array (
      'default' =>
      array (
        'host' => 'localhost',
        'dbname' => 'magento',
        'username' => 'root',
        'password' => '',
        'active' => '1',
      ),
    ),
  ),
  'resource' =>
  array (
    'default_setup' =>
    array (
      'connection' => 'default',
    ),
  ),
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'default',
  'cache_types' =>
  array (
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'customer_notification' => 1,
    'full_page' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    ),
 'translate' => 1,
    'config_webservice' => 1,
  ),
  'install' =>
  array (
    'date' => 'Tue, 13 Dec 2016 12:30:49 +0000',
  ),
'cache' =>
array(
   'frontend' =>
   array(
      'default' =>
      array(
         'backend' => 'Cm_Cache_Backend_Redis',
         'backend_options' =>
         array(
            'server' => '127.0.0.1',
            'port' => '6379'
            ),
    ),
    'page_cache' =>
    array(
      'backend' => 'Cm_Cache_Backend_Redis',
      'backend_options' =>
       array(
         'server' => '127.0.0.1',
         'port' => '6379',
         'database' => '1',
         'compress_data' => '0'
       )
    )
  )
),
);
