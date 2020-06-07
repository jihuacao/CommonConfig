config the server:
python config.py --config_server --server_config_path=/root/ss --server_service_dir=/root/ss --server_port 18888 18890 18892 18894 18896 18898 --server_ip=182.0.0.1

config the normal client:
python config.py --config_client --normal_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 --client_remote_port 18888 18890 18892 18894 18896 18898 --client_remote_ip=182.0.0.1

config the kcptun client:
python config.py --config_client --kcptun_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 18892 18894 18896 18898 --client_kcptun_local_port 18887 18889 18891 18893 18895 18897
