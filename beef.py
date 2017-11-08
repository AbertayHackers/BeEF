#!/usr/bin/env python
# Iain Smart

# Imports
import sys, subprocess, argparse, requests
import simplejson as json


def get_args():
    # Argparse Setup
    parser = argparse.ArgumentParser(description='Pixel for Pixel websites clones using BeEF')

    # Beef password
    parser.add_argument('password', metavar='password', help='Password for BeEF server instance')
    # Site to be cloned
    parser.add_argument('site', help='Site you wish to clone. e.g test.com')
    # Mount point
    parser.add_argument('-m', metavar='MOUNTPOINT', default='/', help='Mount point of cloned site on your BeEF host')
    # Host IP address
    parser.add_argument('-i', metavar='IP', default='127.0.0.1', help='IP address of your BeEF host')
    # Host port
    parser.add_argument('-p', metavar='PORT', default='3000', help='Port number BeEF is running on')
    # Beef username
    parser.add_argument('-u', metavar='USERNAME', default='beef', help='Username for beef')
    # Edit Mode
    parser.add_argument('-e', metavar=('FIND', 'REPLACE'), nargs=2, help='Enables edit mode. E.g. -e string_to_replace string_replacement')

    arguments = parser.parse_args()

    return arguments


def get_api_token():
    # Get BEEF API Token
    try:
        api_token_request = requests.post("http://{}:{}/api/admin/login".format(beef_host, beef_port), data=json.dumps({'username':args.u, 'password':args.password}))
    except requests.exceptions.ConnectionError as e:
        print("[\033[1;31mERROR\033[0m] Could not get API token")
        print("[\033[1;31mERROR\033[0m] BeEF is probably not running")
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(e)
        sys.exit(1)

    try:
        api_token_json = json.loads(api_token_request.text)
    except json.decoder.JSONDecodeError as e: 
        print("[\033[1;31mERROR\033[0m] Did not get valid response from BeEF server")
        print("[INFO] Check BeEF password is correct")
        sys.exit(1)

    api_token = api_token_json['token']

    return api_token


def clone_site(api_token):
    payload = '{' + '"url":"{}", "mount":"{}"'.format(site_to_clone, mount_point) + '}'
    r = requests.post("http://{}:{}/api/seng/clone_page?token={}".format(beef_host, beef_port, api_token), data = payload)
    #r.raise_for_status()
    if r.ok:
    # Returns True if status_code is less than 400
        print("[\033[92mSuccess\033[0m] {} cloned Sucessfully!".format(args.site))
        if args.e and not args.i:
            print("[\033[92mSuccess\033[0m] Editing", args.site)
            subprocess.check_output("sed -i.tmp 's/{}/{}/g' /usr/share/beef-xss/extensions/social_engineering/web_cloner/cloned_pages/{}_mod".format(args.e[0], args.e[1], args.site), shell=True)
            # use sed to find and replace a string
            # TODO: Path is hard coded, expects BeEF to be installed in /usr/share/beef-xss
            payload = '{' + '"url":"{}", "mount":"{}"'.format(site_to_clone, mount_point) + ', "use_existing":"true"}'
            r = requests.post("http://{}:{}/api/seng/clone_page?token={}".format(beef_host, beef_port, api_token), data=payload)
            if r.ok:
            # Returns True if status_code is less than 400
                print("[\033[92mSuccess\033[0m] {} cloned and edited sucessfully!".format(args.site))
                print("[INFO] Visit your clone at http://{ip}:{port}{mountpoint}".format(ip=args.i, port=args.p, mountpoint=mount_point))
                sys.exit(0)
        elif args.e and args.i:
            print("[\033[1;31mERROR\033[0m]] Can't edit cloned page when using remote BeEF instance")
            sys.exit(1)
        else:
            print("[INFO] Visit your clone at http://{ip}:{port}{mountpoint}".format(ip=args.i, port=args.p, mountpoint=mount_point))
            sys.exit(0)
    else:
        print("[\033[1;31mERROR\033[0m] Something's gone wrong...")
        print("[INFO] Have you typed the target URL correctly?")
        print("[INFO] Have you got an internet connection? ;)")
        sys.exit(1)


if __name__ == "__main__":
    args = get_args()

    beef_host = args.i
    beef_port = args.p
    mount_point = args.m
    site_to_clone = "http://{}".format(args.site)

    api_token = get_api_token()
    clone_site(api_token)


