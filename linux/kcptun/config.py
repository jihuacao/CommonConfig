# coding=utf-8
import os
import shutil
import sys
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('--test', dest='Test', action='store_true', help='run in a test mode or not')
parser.add_argument('--config_server', '--cs', dest='ConfigServer', action='store_true', help='generate the server config if this flag is set')
parser.add_argument('--server_listen_port', '--slp', dest='ServerListenPort', default=[], type=int, nargs='+', help='the ports kcptun listen, which is link for the client')
parser.add_argument('--server_target_port', '--stp', dest='ServerTargetPort', default=[], type=int, nargs='+', help='the target port which is used in other app like ss-server and kcptun would send the msg to')
parser.add_argument('--server_target_ip', '--sti', dest='ServerTargetIp', default='', type=str, help='the ip which kcptun processing')
parser.add_argument('--server_config_path', '--scp', dest='ServerConfigPath', type=str, default='./server_config', action='store', help='the path where the server config file saved')
parser.add_argument('--server_executable_dir', '--sed', dest='ServerExecutableDir', type=str, default='./server_executable', action='store', help='the dir where the server executable saved to')
parser.add_argument('--server_service_dir', '--ssd', dest='ServerServiceDir', type=str, default='./server_service', action='store', help='the dir where server service saved to')

parser.add_argument('--config_client', '--cc', dest='ConfigClient', action='store_true', help='generate the client config if this flag is et')
parser.add_argument('--client_local_port', '--clp', dest='ClientLocalPort', default=[], type=int, nargs='+', help='the ports kcptun client local port, which would be use in other app')
parser.add_argument('--client_remote_port', '--crp', dest='ClientRemotePort', default=[], type=int, nargs='+', help='the ports which is called ServerListenPort in kcptun server')
parser.add_argument('--client_remote_ip', '--cri', dest='ClientRemoteIp', type=str, default='', help='the ip which called ServerTargetIp in kcptun server')
parser.add_argument('--client_config_path', '--ccp', dest='ClientConfigPath', type=str, default='./client_config', action='store', help='the path where the client config file saved to')
parser.add_argument('--client_executable_dir', '--ced', dest='ClientExecutableDir', type=str, default='./cilent_executable', action='store', help='the dir where client executable saved to')
parser.add_argument('--client_service_dir', '--csd', dest='ClientServiceDir', type=str, default='./client_service', action='store', help='the dir where client service saved to')

options = parser.parse_args()
print(options)

common_config = {
    "key": "renburugou",
    "crypt": "none",
    "mode": "fast",
    "mtu": 1350,
    "sndwnd": 512,
    "rcvwnd": 512,
    "datashard": 10,
    "parityshard": 3,
    "dscp": 0,
    "nocomp": True,
    "quiet": False,
    "tcp": False,
    "pprof": False
}

if options.ConfigServer is True:
    assert len(options.ServerListenPort) == len(options.ServerTargetPort)
    assert options.ServerTargetIp != ''
    assert options.ServerExecutableDir != ''
    assert options.ServerConfigPath != ''
    base_server_config = {
        "listen": ":18887",
        "target": "target_ip:18888"
    }
    base_server_config.update(common_config)

    server_executable_path = os.path.join(options.ServerExecutableDir, 'server_linux_amd64')
    print('server_executable_path: {0}'.format(server_executable_path))
    base_server_service = \
        "[Unit] \n" \
        "Description=Kcptun Server {2}\n" \
        "After=network.target \n" \
        "[Service] \n" \
        "ExecStart={0} -c {1}\n" \
        "[Install] \n" \
        "WantedBy=multi-user.target \n".format(os.path.abspath(server_executable_path), '{0}', '{1}')

    print('server executable save to: {0}'.format(options.ServerExecutableDir))
    if os.path.exists(options.ServerExecutableDir) is False:
        print('mkdir: {0}'.format(options.ServerExecutableDir))
        os.mkdir(options.ServerExecutableDir) if options.Test is False else None
        shutil.copy('./server_linux_amd64', options.ServerExecutableDir) if options.Test is False else None
        pass

    print('server_config save to: {0}'.format(options.ServerConfigPath))
    if os.path.exists(options.ServerConfigPath) is False:
        print('mkdir: {0}'.format(options.ServerConfigPath))
        os.mkdir(options.ServerConfigPath) if options.Test is False else None
        pass

    print('server_service save to: {0}'.format(options.ServerServiceDir ))
    if os.path.exists(options.ServerServiceDir) is False:
        print('mkdir: {0}'.format(options.ServerServiceDir))
        os.mkdir(options.ServerServiceDir) if options.Test is False else None
        pass

    for lp, tp in zip(options.ServerListenPort, options.ServerTargetPort):
        base_server_config['listen'] = ':{0}'.format(lp)
        base_server_config['target'] = '{0}:{1}'.format(options.ServerTargetIp, tp)

        def save_config_to_json(server_config_file_path, config):
            with open(server_config_file_path, 'w') as fp:
                json.dump(config, fp, indent=4)
            pass
        server_config_file_path = os.path.join(options.ServerConfigPath, 'kcptun-server-config-{0}.json'.format(lp))
        print('server_config save to {0}'.format(server_config_file_path))
        save_config_to_json(server_config_file_path, base_server_config) if options.Test is False else None

        def save_server_service(server_service_file_path, server_service):
            with open(server_service_file_path, 'w') as fp:
                fp.write(server_service)
                pass
            pass
        server_service = base_server_service.format(os.path.abspath(server_config_file_path), lp)
        server_service_file_path = os.path.join(options.ServerServiceDir, 'kcptun-server-{0}.service'.format(lp))
        print('server_service save to {0}'.format(server_service_file_path))
        save_server_service(server_service_file_path, server_service) if options.Test is False else None
        pass
    pass

if options.ConfigClient is True:
    assert len(options.ClientLocalPort) == len(options.ClientRemotePort)
    assert options.ClientRemoteIp != ''
    assert options.ClientExecutableDir != ''
    assert options.ClientConfigPath != ''
    base_client_config = {
        "localaddr": ":18887",
        "remoteaddr": "target_ip:18887"
    }
    base_client_config.update(common_config)

    client_executable_path = os.path.join(options.ClientExecutableDir, 'client_linux_amd64')
    print('client_executable_path: {0}'.format(client_executable_path))
    base_client_service = \
        "[Unit] \n" \
        "Description=Kcptun Client {2}\n" \
        "After=network.target \n" \
        "[Service] \n" \
        "ExecStart={0} -c {1}\n" \
        "[Install] \n" \
        "WantedBy=multi-user.target \n".format(os.path.abspath(client_executable_path), '{0}', '{1}')

    print('clinet executable save to: {0}'.format(options.ClientExecutableDir))
    if os.path.exists(options.ClientExecutableDir) is False:
        print('mkdir: {0}'.format(options.ClientExecutableDir))
        os.mkdir(options.ClientExecutableDir) if options.Test is False else None
        shutil.copy('./client_linux_amd64', options.ClientExecutableDir) if options.Test is False else None
        pass

    print('client_config save to: {0}'.format(options.ClientConfigPath))
    if os.path.exists(options.ClientConfigPath) is False:
        print('mkdir: {0}'.format(options.ClientConfigPath))
        os.mkdir(options.ClientConfigPath) if options.Test is False else None
        pass

    print('client_service save to: {0}'.format(options.ClientServiceDir ))
    if os.path.exists(options.ClientServiceDir) is False:
        print('mkdir: {0}'.format(options.ClientServiceDir))
        os.mkdir(options.ClientServiceDir) if options.Test is False else None
        pass

    for lp, rp in zip(options.ClientLocalPort, options.ClientRemotePort):
        base_client_config['localaddr'] = ':{0}'.format(lp)
        base_client_config['remoteaddr'] = '{0}:{1}'.format(options.ClientRemoteIp, rp)

        def save_config_to_json(client_config_file_path, config):
            with open(client_config_file_path, 'w') as fp:
                json.dump(config, fp, indent=4)
            pass
        client_config_file_path = os.path.join(options.ClientConfigPath, 'kcptun-client-config-{0}.json'.format(lp))
        print('client_config save to {0}'.format(client_config_file_path))
        save_config_to_json(client_config_file_path, base_client_config) if options.Test is False else None

        def save_client_service(client_service_file_path, client_service):
            with open(client_service_file_path, 'w') as fp:
                fp.write(client_service)
                pass
            pass
        client_service = base_client_service.format(os.path.abspath(client_config_file_path), lp)
        client_service_file_path = os.path.join(options.ClientServiceDir, 'kcptun-client-{0}.service'.format(lp))
        print('client_service save to {0}'.format(client_service_file_path))
        save_client_service(client_service_file_path, client_service) if options.Test is False else None
        pass
    pass
