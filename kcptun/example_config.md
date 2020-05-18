config the server:
python config.py --config_server --server_executable_dir=/home/sins/kcptun --server_config_path=/home/sins/kcptun --server_service_dir=/home/sins/kcptun --server_target_port 18888 18890 --server_listen_port 18887 18889 --server_target_ip=182.0.0.1 

config the client:
python config.py --config_client --client_executable_dir=/home/sins/kcptun --client_config_path=/home/sins/kcptun --client_service_dir=/home/sins/kcptun --client_remote_port 18887 18889 --client_local_port 18887 18889 --client_remote_ip=182.0.0.1
