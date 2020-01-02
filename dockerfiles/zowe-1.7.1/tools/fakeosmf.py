#!/usr/bin/env python
import sys, getopt, os, stat, pwd, grp, datetime
from flask import Flask, jsonify, abort, make_response, request
import json
import re


app = Flask(__name__)
@app.route('/')
def index():
    print(request.headers)
@app.route('/zosmf/restjobs/jobs', methods=['PUT'])
def submit_job():
    data = {
        "jobid": "JOB00025","jobname":"TESTJOBX","subsystem":"","owner":"IBMUSER",
        "status":"INPUT","type":"JOB","class":"A","retcode":"0000",
        "url":"https:\/\/%s\/zosmf\/restjobs\/jobs\/TESTJOBX\/JOB00025" % (request.headers['Host']),
        "files-url":"https:\/\/%s\/zosmf\/restjobs\/jobs\/TESTJOBX\/JOB00025\/files" % (request.headers['Host'])
    }
    return jsonify(data)

@app.route('/zosmf/restjobs/jobs', methods=['GET'])
def get_job_status():
    data = [{"owner":"CUST006","phase":20,"subsystem":"JES2","phase-name":"Job is on the hard copy queue",
    "job-correlator":"J0005056157.....D61EE170.......:","type":"JOB",
    "url":("https:\/\/%s\/zosmf\/restjobs\/jobs\/J0005056157.....D61EE170.......%%3A"% ((request.headers['Host']))),
    "jobid":"JOB05056","class":"A",
    "files-url":("https:\/\/%s\/zosmf\/restjobs\/jobs\/J0005056157.....D61EE170.......%%3A\/files"% ((request.headers['Host']))),
    "jobname":"MARBIND","status":"OUTPUT","retcode":"CC 0000"}]

    print(data)
    resp = make_response(jsonify(data), 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)

    return resp    

@app.route('/zosmf/restjobs/jobs/<path:pth>', methods=['GET'])
def get_job_files(pth):
    if "records" in pth:
        resp = make_response("dummy content %s" % pth, 200)
    else:
        data = [
        {
            "byte-count": 0,
            "class": "Z",
            "ddname": "JESMSGLG",
            "id": 2,
            "job-correlator": "T0002201USILDAMDD7374723.......:",
            "jobid": "TSU02201",
            "jobname": "VLCVI01",
            "lrecl": 133,
            "procstep": None,
            "recfm": "UA",
            "record-count": 2,
            "records-url": "https://%s/zosmf/restjobs/jobs/T0002201USILDAMDD7374723.......%%3A/files/2/records" % (request.headers['Host']),
            "stepname": "JES2",
            "subsystem": "JES2"
        },
        {
            "byte-count": 2924,
            "class": "Z",
            "ddname": "JESJCL",
            "id": 3,
            "job-correlator": "T0002201USILDAMDD7374723.......:",
            "jobid": "TSU02201",
            "jobname": "VLCVI01",
            "lrecl": 136,
            "procstep": None,
            "recfm": "V",
            "record-count": 47,
            "records-url": "https://%s/zosmf/restjobs/jobs/T0002201USILDAMDD7374723.......%%3A/files/3/records" % (request.headers['Host']),
            "stepname": "JES2",
            "subsystem": "JES2"
        },
        {
            "byte-count": 0,
            "class": "Z",
            "ddname": "JESYSMSG",
            "id": 4,
            "job-correlator": "T0002201USILDAMDD7374723.......:",
            "jobid": "TSU02201",
            "jobname": "VLCVI01",
            "lrecl": 137,
            "procstep": None,
            "recfm": "VA",
            "record-count": 2,
            "records-url": "https://%s/zosmf/restjobs/jobs/T0002201USILDAMDD7374723.......%%3A/files/4/records" % (request.headers['Host']),
            "stepname": "JES2",
            "subsystem": "JES2"
        },
        {
            "byte-count": 0,
            "class": "Z",
            "ddname": "SYSOUT",
            "id": 101,
            "job-correlator": "T0002201USILDAMDD7374723.......:",
            "jobid": "TSU02201",
            "jobname": "VLCVI01",
            "lrecl": 121,
            "procstep": "NORGNLMT",
            "recfm": "FBA",
            "record-count": 0,
            "records-url": "https://%s/zosmf/restjobs/jobs/T0002201USILDAMDD7374723.......%%3A/files/101/records" % (request.headers['Host']),
            "stepname": "IZUFPROC",
            "subsystem": "JES2"
        }
    ]

        print(data)
        resp = make_response(jsonify(data), 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)

    return resp    


def permissions_to_unix_name(st):
    is_dir = 'd' if stat.S_ISDIR(st.st_mode) else '-'
    dic = {'7':'rwx', '6' :'rw-', '5' : 'r-x', '4':'r--', '0': '---'}
    perm = str(oct(st.st_mode)[-3:])
    return is_dir + ''.join(dic.get(x,x) for x in perm)

@app.route('/zosmf/restfiles/fs')
def list_files():
    print(request.data)
    local_files=[]
    pth = request.args.get('path', '/')

    for d in os.listdir(pth):
        stats=os.stat(os.path.join(pth,d))
        local_files+=[{
            "name":d, 
            "mode": permissions_to_unix_name(stats), #"drwxr-xr-x", 
            "size": stats.st_size, 
            "uid": stats.st_uid, 
            "user":pwd.getpwuid(stats.st_uid)[0], 
            "gid":stats.st_gid, 
            "group":grp.getgrgid(stats.st_gid)[0], 
            "mtime":datetime.datetime.fromtimestamp(stats.st_mtime).strftime("%Y-%m-%dT%H:%M:%S")#, "2019-12-23T05:07:26"
            }]

    
    data = {"items":[
        {"name":".", "mode":"drwxr-xr-x", "size":24576, "uid":0, "user":"STCSYS", "gid":32, "group":"OMVSDFG", "mtime":"2019-12-23T05:07:26"},
        {"name":"..", "mode":"dr-xr-xr-x", "size":0, "uid":0, "user":"STCSYS", "gid":2, "group":"TTY", "mtime":"2019-12-23T14:38:25"},
        {"name":"dummy-dir", "mode":"dr-xr-xr-x", "size":0, "uid":0, "user":"STCSYS", "gid":2, "group":"TTY", "mtime":"2019-12-23T14:38:25"},
        {"name":"dummy-file", "mode":"-rw-r--r--", "size":0, "uid":0, "user":"STCSYS", "gid":32, "group":"OMVSDFG", "mtime":"2019-06-24T06:14:50"},        
        ],"returnedRows":4,"totalRows":4,"JSONversion":1}

    if len(local_files)>0:
        data['items'].extend(local_files)
        data['returnedRows']+=len(local_files)
        data['totalRows']+=data['returnedRows']

    resp = make_response(jsonify(data), 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)
    return resp


@app.route('/zosmf/restfiles/fs/<path:pth>')
def content_of_file(pth):
    print(request.data)
    if "dummy" in pth:
        resp = make_response("dummy content of /%s"%(pth), 200)
    else:
        if request.headers.get("X-IBM-Data-Type","text")=="binary":
            with open("/"+pth,"rt") as f:
                content="\n".join(f.readlines())
        else:
            with open("/"+pth,"rb") as f:
                content=f.read()

        resp = make_response(content, 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)
    return resp


@app.route('/zosmf/restfiles/ds/<data_set>/member')
def list_dataset(data_set):
    print(request.data)
    data = {
        "items" : [
            
            {"member" : "MARBLE"},
            {"member" : "MARBLE01"},
            {"member" : "MARBLE02"},
            {"member" : "MARBLE03"},
            {"member" : "MARBLE04"},
        ],
        "returned rows" : 2,
        "JSONversion" : 1
    }

    resp = make_response(jsonify(data), 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)
    return resp

@app.route('/zosmf/info', methods=['GET'])
def info():
    print(request.data)
    print(request.headers)
    if "X-CSRF-ZOSMF-HEADER" in request.headers:
        data={
            "api_version": "1",
            "plugins": [
                {
                    "pluginDefaultName": "z/OS Operator Consoles",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA230;PH12708P;2019-06-20T04:29:14"
                },
                {
                    "pluginDefaultName": "Software Deployment",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA234;PH15703P;2019-08-27T14:56:58"
                },
                {
                    "pluginDefaultName": "Variables",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA230;PI96931P;2018-05-22T06:55:26"
                },
                {
                    "pluginDefaultName": "Workflow",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA237;PH12733P;2019-06-12T05:58:36"
                },
                {
                    "pluginDefaultName": "IncidentLog",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA235;PH11149P;2019-05-16T02:14:12"
                },
                {
                    "pluginDefaultName": "Network Configuration Assistant",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA23A;PH14555;2019-10-03T04:20:37"
                },
                {
                    "pluginDefaultName": "Sysplex Management",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA230;PH10944P;2019-05-28T02:03:52"
                },
                {
                    "pluginDefaultName": "ISPF",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA231;PH08534P;2019-03-27T08:54:23"
                },
                {
                    "pluginDefaultName": "Import Manager",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA230;PI96730P;2019-01-17T09:21:36"
                },
                {
                    "pluginDefaultName": "ResourceMonitoring",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA232;PH06809P;2019-02-28T05:14:30"
                },
                {
                    "pluginDefaultName": "WorkloadManagement",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA233;PH08950P;2019-03-13T05:42:52"
                },
                {
                    "pluginDefaultName": "Capacity Provisioning",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA236;PH09942P;2019-03-27T07:50:00"
                },
                {
                    "pluginDefaultName": "Cloud Provisioning",
                    "pluginStatus": "ACTIVE",
                    "pluginVersion": "HSMA230;PH12793P;2019-07-16T06:59:19"
                }
            ],
            "zos_version": "04.26.00",
            "zosmf_full_version": "26.0",
            "zosmf_hostname": request.headers['Host'].split(":")[0],
            "zosmf_port": str(request.headers['Host'].split(":")[1]),
            "zosmf_saf_realm": "SAFRealm",
            "zosmf_version": "26"
        }
    else:
        data= {
        "errorID": "IZUG846W",
        "errorMsg": "IZUG846W: An HTTP request for a z/OSMF REST service was received from a remote site. The request was rejected, however, because the remote site \"\" is not permitted to z/OSMF server \"IZUSVR\" on target system \"%s\" ." % (request.headers['Host'])
        }    
    resp = make_response(jsonify(data), 200)
    if 'Authorization' in request.headers:
        resp.set_cookie('LtpaToken2','fakeToken', secure=True, httponly=True)

    return resp


if __name__ == '__main__':
    # read commandline arguments, first
    fullCmdArguments = sys.argv

    # - further arguments
    argumentList = fullCmdArguments[1:]

    unixOptions = "hp:dk:c:n:"
    gnuOptions = ["help", "port=", "debug","key=","cert=","hostname="]

    try:
        arguments, values = getopt.getopt(argumentList, unixOptions, gnuOptions)
    except getopt.error as err:
        # output error, and return with an error code
        print (str(err))
        sys.exit(2)
    
    debug=False
    port=5001
    host='0.0.0.0'
    key='localhost.key'
    cert='localhost.pem'

    for currentArgument, currentValue in arguments:
        if currentArgument in ("-d", "--debug"):
            print ("enabling debug mode")
            debug=True
        elif currentArgument in ("-h", "--help"):
            print ("fakeOSMF [-d|--debug] [-p|--port port] [-k|--key localhost.key] [-c|--cert localhost.pem] [-n|--hostname 0.0.0.0]")
        elif currentArgument in ("-p", "--port"):
            port=int(currentValue)
        elif currentArgument in ("-k", "--key"):
            key=currentValue
        elif currentArgument in ("-c", "--cert"):
            cert=currentValue
        elif currentArgument in ("-c", "--cert"):
            cert=currentValue
        elif currentArgument in ("-n", "--hostname"):
            host=currentValue

    print("%s %s -p %i -k %s -c %s -n %s"%(sys.argv[0],"-d" if debug else "", port,key,cert,host))
    app.run(debug=debug,port=port,host=host,ssl_context=(cert,key))
