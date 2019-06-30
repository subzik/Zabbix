import os, requests, json, sys, simplejson, socket, subprocess
from requests.auth import HTTPBasicAuth

zabbix_server = "192.168.0.50"
zabbix_api_admin_name = "Admin"
zabbix_api_admin_password = "zabbix"
zabbix_hostgroup = "CloudHosts"
zabbix_ctemplate = "Custom template"

def hostname():
    subprocess.call("hostname", shell=True)
hostname = hostname()

def post(request):
    headers = {'content-type': 'application/json'}
    return requests.post(
        "http://" + zabbix_server + "/zabbix" + "/api_jsonrpc.php",
         data=json.dumps(request),
         headers=headers,
         auth=HTTPBasicAuth(zabbix_api_admin_name, zabbix_api_admin_password)
    )


auth_token = post({
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
         "user": zabbix_api_admin_name,
         "password": zabbix_api_admin_password
     },
    "auth": None,
    "id": 0}
).json()["result"]


def add_hostgroups(zabbix_hostgroup):
    """Creating hostgroup"""
    post({
    "jsonrpc": "2.0",
    "method": "hostgroup.create",
    "params": {
        "name": zabbix_hostgroup #will change to input
    },
    "auth": auth_token,
    "id": 1
    })
#print add_hostgroups(zabbix_hostgroup)

def get_groupid(zabbix_hostgroup):
    """Get groupID"""
    result = post({
        'jsonrpc': '2.0',
        'method': 'hostgroup.get',
        'params': {
            'output': 'extend',
            'filter': {
                'name': [
                    zabbix_hostgroup
                ]
            }
        },
        'auth': auth_token,
        'id': 1
    }).json()['result']
    return result[0]['groupid']

ids = get_groupid(zabbix_hostgroup)

def add_template():
    """Creating template"""
    post({
        "jsonrpc": "2.0",
        "method": "template.create",
        "params": {
            "host": zabbix_ctemplate,
            "groups": {
                "groupid": ids
            }
        },
        "auth": auth_token,
        "id": 1
        })


def get_template_id(zabbix_ctemplate):
    """Get templateID"""
    result = post({
        'jsonrpc': '2.0',
        'method': 'template.get',
        'params': {
            'output': 'extend',
            'filter': {
                'host': [
                    zabbix_ctemplate
                ]
            }
        },
        'auth': auth_token,
        'id': 1
    }).json()['result']
    return result[0]['templateid']
tmpid = get_template_id(zabbix_ctemplate)


def get_IP():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        print host_ip
    except:
        print("Unable to get Hostname and IP")
ip = get_IP()

def register_host(hostname, ip):
    post({
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": hostname,
            "templates": [{
                "templateid": tmpid
            }],
            "interfaces": [{
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            }],
            "groups": [
                {"groupid": ids}
            ]
        },
        "auth": auth_token,
        "id": 1
    })

register_host(hostname, ip)