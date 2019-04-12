# Readme
This package supports other packages that I write. I ended up using it so often that I separated it out.

# Installation
```bash
git clone https://github.com/alexmarder/traceutils
cd traceutils
# install required packages
pip install -r requirements.txt
# compile cython code
python setup.py sdist bdist_wheel
# install traceutils in developer mode
pip install -e .
```
_I’m not sure why it has to be installed in developer mode but I can’t get the headers to link without it._
