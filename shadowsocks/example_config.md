config the server:
python config.py --config_server --server_config_path=/home/sins/shadowsocks --server_service_dir=/home/sins/shadowsocks --server_ip=182.0.0.1 --server_port 18888 18890

config the normal client:
python config.py --config_client --normal_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 --client_remote_port 18888 18890 --client_remote_ip=182.0.0.1

config the kcptun client:
python config.py --config_cliten --kcptun_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 --client_kcptun_local_port 18887 18889
