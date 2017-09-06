# BeEF-scripts
automating BeEF tasks, mostly site cloning stuff http://beefproject.com/

## Install

### No Preexisting BeEF

```
git clone git://github.com/AbertayHackers/BeEF-scripts
cd BeEF-scripts
./install-beef.sh
./beef.py example.com
```


### Preexisting BeEF

Start BeEF Server

On Kali: `cd /usr/share/beef-xss && ./beef &`

```
git clone git://github.com/AbertayHackers/BeEF-scripts
cd BeEF-scripts
./beef.py example.com
```


## Web Cloner

Relevant BeEF Blog: [BeEF web cloning, BeEF mass mailing, Social Engineering with better BeEF!](http://blog.beefproject.com/2012/09/beef-web-cloning-beef-mass-mailing.html)

With the BeEF Server running `example.com/login.aspx` can be cloned to appear on `http://[BeEF]/login.aspx` using `curl` or `beef.py`.

`[BeEF]` = `IP:PORT` (Default: `127.0.0.1:3000`)


### `curl`

```
curl -H "Content-Type: application/json; charset=UTF-8" -d
'{"url":"https://example.com/login.aspx", "mount":"/login.aspx"}'
-X POST http://[BeEF]/api/seng/clone_page?token=[token];
```
From Relevant BeEF Blog.


### `beef.py`

```
usage: beef.py [-h] [-m M] [-i I] [-p P] [site]

Pixel for Pixel websites clones using BeEF

positional arguments:
  site        Site you wish to clone. e.g test.com

optional arguments:
  -h, --help  show this help message and exit
  -m M        Mount point of cloned site on your BeEF host e.g. -m /clonedsite
  -i I        IP address of your BeEF host
  -p P        Port number BeEF is running on
```

`./beef.py -m /login.aspx example.com/login.aspx`
