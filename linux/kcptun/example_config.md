config the server:
python config.py --config_server --server_executable_dir=/root/kcptun --server_config_path=/root/kcptun --server_service_dir=/root/kcptun --server_target_port 18888 --server_target_ip=182.0.0.1 

config the client:
python config.py --config_client --client_executable_dir=/home/sins/kcptun --client_config_path=/home/sins/kcptun --client_service_dir=/home/sins/kcptun --client_remote_port 18887 --client_remote_ip=182.0.0.1
