#!/usr/bin/env python
# Iain Smart

# Imports
import sys, subprocess, argparse, requests
import simplejson as json

# Argparse Setup
parser = argparse.ArgumentParser(description='Pixel for Pixel websites clones using BeEF')

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
# Beef password
parser.add_argument('-P', metavar='PASSWORD', default='beef', help='Password for beef')
# Edit Mode
parser.add_argument('-e', metavar=('FIND', 'REPLACE'), nargs=2, help='Enables edit mode. E.g. -e string_to_replace string_replacement')

args = parser.parse_args()

beefHost = args.i
beefPort = args.p
mountPoint = args.m
siteToClone = "http://{}".format(args.site)

# Get BEEF API Token
try:
    beefTokenRequest = requests.post("http://{}:{}/api/admin/login".format(beefHost, beefPort), data=json.dumps({'username':args.u, 'password':args.P}))
except requests.exceptions.ConnectionError as e:
    print("[\033[1;31mERROR\033[0m] Could not get API token")
    print("[\033[1;31mERROR\033[0m] BeEF is probably not running")
    sys.exit(1)
except requests.exceptions.RequestException as e:
    print(e)
    sys.exit(1)

try:
    beefTokenJSON = json.loads(beefTokenRequest.text)
except json.decoder.JSONDecodeError as e: 
    print("[\033[1;31mERROR\033[0m] Did not get valid response from BeEF server")
    print("[INFO] Check BeEF password is correct")
    sys.exit(1)

beefToken = beefTokenJSON['token']

payload = '{' + '"url":"{}", "mount":"{}"'.format(siteToClone, mountPoint) + '}'
r = requests.post("http://{}:{}/api/seng/clone_page?token={}".format(beefHost, beefPort, beefToken), data = payload)
#r.raise_for_status()
if r.ok:
# Returns True if status_code is less than 400
    print("[*] {} Cloned Sucessfully!".format(args.site))
    if args.e and not args.i:
        print("[*] Editing", args.site)
        subprocess.check_output("sed -i.tmp 's/{}/{}/g' /usr/share/beef-xss/extensions/social_engineering/web_cloner/cloned_pages/{}_mod".format(args.e[0], args.e[1], args.site), shell=True)
        # use sed to find and replace a string
        # TODO: Path is hard coded, expects BeEF to be installed in /usr/share/beef-xss
        payload = '{' + '"url":"{}", "mount":"{}"'.format(siteToClone, mountPoint) + ', "use_existing":"true"}'
        r = requests.post("http://{}:{}/api/seng/clone_page?token={}".format(beefHost, beefPort, beefToken), data=payload)
        if r.ok:
        # Returns True if status_code is less than 400
            print("[*] {} Cloned and edited sucessfully!".format(args.site))
            print("[*] Visit your clone at http://{ip}:{port}{mountpoint}".format(ip=args.i, port=args.p, mountpoint=mountPoint))
            sys.exit(0)
    elif args.e and args.i:
        print("[*] Can't edit cloned page when using remote BeEF instance")
        sys.exit(1)
    else:
        print("[*] Visit your clone at http://{ip}:{port}{mountpoint}".format(ip=args.i, port=args.p, mountpoint=mountPoint))
        sys.exit(0)
else:
    print("[*] Something's gone wrong...")
    print("[*] Have you typed the target URL correctly?")
    print("[*] Have you got an internet connection? ;)")
    sys.exit(1)
