### Directory for third party libraries

`userver` placed into this directory would be used if there's no installed
userver framework. For example:

```
cd /data/code
git clone --depth 1 https://github.com/userver-framework/userver.git
git clone --depth 1 https://github.com/userver-framework/service_template.git
ln -s /data/code/userver /data/code/service_template/third_party/userver
```
