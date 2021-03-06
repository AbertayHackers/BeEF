#!/usr/bin/env python3
# Iain Smart
"""Do stuff with BeEF"""

# Imports
import sys
import subprocess
import argparse
import requests
import simplejson as json

# Define output messages
FATAL = "\033[1;31m[FATAL]\033[0m"
WARNING = "\033[1;33m[WARNING]\033[0m"
PASS = "\033[1;32m[PASS]\033[0m"
INFO = "\033[1;36m[INFO]\033[0m"


def get_args():
    """Argparse Setup"""

    parser = argparse.ArgumentParser(description='Pixel for Pixel websites clones using BeEF')

    # Beef password
    parser.add_argument('password', metavar='password', help='Password for BeEF server instance')
    # Site to be cloned
    parser.add_argument('site', help='Site you wish to clone. e.g test.com')
    # Mount point
    parser.add_argument('-m', metavar='MOUNTPOINT', default='/',
                        help='Mount point of cloned site on your BeEF host')
    # Host IP address
    parser.add_argument('-i', metavar='IP', default='127.0.0.1', help='IP address of your BeEF host')
    # Host port
    parser.add_argument('-p', metavar='PORT', default='3000', help='Port number BeEF is running on')
    # Beef username
    parser.add_argument('-u', metavar='USERNAME', default='beef', help='Username for beef')
    # Edit Mode
    parser.add_argument('-e', metavar=('FIND', 'REPLACE'), nargs=2,
                        help='Enables edit mode. E.g. -e string_to_replace string_replacement')

    arguments = parser.parse_args()

    return arguments


def get_api_token():
    """Get BEEF API Token"""

    try:
        api_token_request = requests.post("http://{host}:{port}/api/admin/login"
                                          .format(host=BEEF_HOST, port=BEEF_PORT),
                                          data=json.dumps({'username': ARGS.u, 'password': ARGS.password}))

    except requests.exceptions.ConnectionError as err:
        print("{status} Could not get API token".format(status=FATAL))
        print("{status} BeEF is probably not running".format(status=INFO))
        sys.exit(1)
    except requests.exceptions.RequestException as err:
        print(err)
        sys.exit(1)

    try:
        api_token_json = json.loads(api_token_request.text)
    except json.decoder.JSONDecodeError as err:
        print("{status} Did not get valid response from BeEF server".format(status=FATAL))
        print("{status} Check BeEF password is correct".format(status=INFO))
        sys.exit(1)

    api_token = api_token_json['token']

    return api_token


def clone_site(api_token):
    """ Clone site """

    payload = '{' + '"url":"{target}", "mount":"{path}"'.format(target=SITE_TO_CLONE, path=MOUNT_POINT) + '}'
    request = requests.post("http://{host}:{port}/api/seng/clone_page?token={token}"
                            .format(host=BEEF_HOST, port=BEEF_PORT, token=api_token), data=payload)

    if request.ok:
        # Returns True if status_code is less than 400
        print("{status} {site} cloned Sucessfully!".format(status=PASS, site=ARGS.site))
        if ARGS.e:

            print("{status} Editing {site}".format(status=PASS, site=ARGS.site))
            subprocess.check_output("sed -i.tmp 's/{}/{}/g'\
                                    /root/Desktop/beef/extensions/social_engineering/web_cloner/cloned_pages/{}_mod"
                                    .format(ARGS.e[0], ARGS.e[1], ARGS.site), shell=True)
            # use sed to find and replace a string
            # TODO: Path is hard coded, expects BeEF to be installed in /usr/share/beef-xss

            payload = '{' + '"url":"{}", "mount":"{}"'.format(SITE_TO_CLONE, MOUNT_POINT) + ', "use_existing":"true"}'

            request = requests.post("http://{host}:{port}/api/seng/clone_page?token={token}"
                                    .format(host=BEEF_HOST, port=BEEF_PORT, token=api_token), data=payload)

            if request.ok:
                # Returns True if status_code is less than 400
                print("{status} {site} cloned and edited sucessfully!".format(status=PASS, site=ARGS.site))
                print("{status} Visit your clone at http://{ip}:{port}{mount_point}"
                      .format(status=INFO, ip=ARGS.i, port=ARGS.p, mount_point=MOUNT_POINT))

                sys.exit(0)

        else:
            print("{status} Visit your clone at http://{ip}:{port}{mount_point}"
                  .format(status=INFO, ip=ARGS.i, port=ARGS.p, mount_point=MOUNT_POINT))

            sys.exit(0)
    else:

        print("{status} Something's gone wrong...".format(status=FATAL))
        print("{status} Have you typed the target URL correctly?".format(status=INFO))
        print("{status} Have you got an internet connection? ;)".format(status=INFO))
        sys.exit(1)


if __name__ == "__main__":
    ARGS = get_args()

    BEEF_HOST = ARGS.i
    BEEF_PORT = ARGS.p
    MOUNT_POINT = ARGS.m
    SITE_TO_CLONE = "http://{site}".format(site=ARGS.site)

    TOKEN = get_api_token()
    clone_site(TOKEN)
