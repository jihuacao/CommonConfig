config the server:
python config.py --config_server --server_config_path=/root/ss --server_service_dir=/root/ss --server_port 18888 18890 18892 18894 18896 18898 18900 18902 18904 18906 18908 18910 18912 18914 18916 18918 18920 18922 18924 18926 18928 18930 18932 18934 18936 18938 18940 18942 18944 18946 18948 18950 18952 18954 18956 18958 18960 18962 18964 18966 18968 18970 18972 18974 18976 18978 18980 18982 18984 18986 18988 18990 18992 18994 18996 18998 19000 --server_ip=182.0.0.1

config the normal client:
python config.py --config_client --normal_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 --client_remote_port 18888 18890 18892 18894 18896 18898 --client_remote_ip=182.0.0.1

config the kcptun client:
python config.py --config_client --kcptun_client --client_config_path=/home/sins/shadowsocks --client_service_dir=/home/sins/shadowsocks --client_local_port 18888 18890 18892 18894 18896 18898 --client_kcptun_local_port 18887 18889 18891 18893 18895 18897
