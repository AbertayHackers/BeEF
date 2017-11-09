# BeEF
Automating website cloning with [BeEF](http://beefproject.com/)  

## Web Cloner

Relevant BeEF blog: [BeEF web cloning, BeEF mass mailing, Social Engineering with better BeEF!](http://blog.beefproject.com/2012/09/beef-web-cloning-beef-mass-mailing.html)

With the BeEF Server running `example.com/login.aspx` can be cloned to appear on `http://[BeEF]/login.aspx` using `curl` or `beef.py`.

`[BeEF]` = `IP:PORT` (Default: `127.0.0.1:3000`)


### `curl`

From Relevant BeEF blog.
```
curl -H "Content-Type: application/json; charset=UTF-8" -d
'{"url":"https://example.com/login.aspx", "mount":"/login.aspx"}'
-X POST http://[BeEF]/api/seng/clone_page?token=[token];
```


### `beef.py`

```
usage: beef.py [-h] [-m MOUNTPOINT] [-i IP] [-p PORT] [-u USERNAME]
               [-e FIND REPLACE]
               password site

Pixel for Pixel websites clones using BeEF

positional arguments:
  password         Password for BeEF server instance
  site             Site you wish to clone. e.g test.com

optional arguments:
  -h, --help       show this help message and exit
  -m MOUNTPOINT    Mount point of cloned site on your BeEF host
  -i IP            IP address of your BeEF host
  -p PORT          Port number BeEF is running on
  -u USERNAME      Username for beef
  -e FIND REPLACE  Enables edit mode. E.g. -e string_to_replace
                   string_replacement

```
```
./beef.py -m /login.aspx {password} example.com/login.aspx 
```
## Requirements
- Python 2 or 3 
  - (Preferably 3)

## I do not have BeEF

The BeEF Wiki has install [instructions](https://github.com/beefproject/beef/wiki/Installation).

## I have BeEF

### Change default password

**If you do not change the default password** you will have to copy the password from `stdout` each time you start BeEF.

```
[!] Warning: Default username and weak password in use!
|_  New password for this instance: b37c2b8597914c934f3fa5571a942325
```

If the default password is set newer versions of BeEF will generate a 16 byte password each time the server is started. See #1 for more info. 


The password is set at line 20 of `config.yaml`. The default password is `beef`, change this to anything other than `beef[0-9]` or `passw[o0]rd[0-9]`.

### Get `AbertayHackers/BeEF`

```
git clone git://github.com/AbertayHackers/BeEF
```

### Install Python Dependencies

```
cd BeEF
pip install -r requirements.txt
```

## Start BeEF Server

Kali:
```
cd /usr/share/beef-xss 
./beef 
```

From manual install: 
```
cd beef
./beef
```
