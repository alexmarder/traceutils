import sys

# from Cython.Distutils import build_ext
from setuptools import setup, find_packages
from setuptools.extension import Extension
# from Cython.Build import cythonize

exec(open('traceutils/version.py').read())

if 'build_ext' in sys.argv:
    from Cython.Distutils import build_ext
    use_cython = True
else:
    use_cython = False

ext_pyx = '.pyx' if use_cython else '.c'
ext_py = '.py' if use_cython else '.c'

extensions_names = {
    'traceutils.utils.utils': ['traceutils/utils/utils' + ext_pyx],
    'traceutils.utils.net': ['traceutils/utils/net' + ext_pyx],
    'traceutils.utils.dicts': ['traceutils/utils/dicts' + ext_pyx],
    'traceutils.file2.file2': ['traceutils/file2/file2' + ext_pyx],
    'traceutils.as2org.as2org': ['traceutils/as2org/as2org' + ext_pyx],
    'traceutils.bgp.bgp': ['traceutils/bgp/bgp' + ext_pyx],
    'traceutils.bgpreader.reader': ['traceutils/bgpreader/reader' + ext_pyx],
    'traceutils.radix.radix_prefix': ['traceutils/radix/radix_prefix' + ext_pyx],
    'traceutils.radix.radix_node': ['traceutils/radix/radix_node' + ext_pyx],
    'traceutils.radix.radix_tree': ['traceutils/radix/radix_tree' + ext_pyx],
    'traceutils.radix.radix': ['traceutils/radix/radix' + ext_pyx],
    'traceutils.radix.ip2as': ['traceutils/radix/ip2as' + ext_pyx],
    'traceutils.radix.ip2ases': ['traceutils/radix/ip2ases' + ext_pyx],
    'traceutils.radix.ip2data': ['traceutils/radix/ip2data' + ext_pyx],
    'traceutils.scamper.hop': ['traceutils/scamper/hop' + ext_pyx],
    'traceutils.scamper.atlas': ['traceutils/scamper/atlas' + ext_pyx],
    'traceutils.scamper.warts': ['traceutils/scamper/warts' + ext_pyx],
    'traceutils.scamper.utils': ['traceutils/scamper/utils' + ext_pyx],
    'traceutils.scamper.pyatlas': ['traceutils/scamper/py_atlas' + ext_py],
    'traceutils.progress.bar': ['traceutils/progress/bar' + ext_py],
    # 'traceutils.traceparse': ['traceparse.py']
}

extensions = [Extension(k, v) for k, v in extensions_names.items()]
package_data = {k: ['*.pxd', '*pyx', '*.py'] for k in extensions_names}

if use_cython:
    from Cython.Build import cythonize
    extensions = cythonize(
        extensions,
        compiler_directives={'language_level': '3', 'embedsignature': True},
        annotate=True
    )

setup(
    name="traceutils",
    version=__version__,
    author='Alex Marder',
    description="Various packages for traceroute and BGP dump analysis.",
    url="https://github.com/alexmarder/traceutils",
    packages=find_packages(),
    install_requires=['ujson', 'orjson', 'cython', 'jsonschema'],
    # cmdclass={'build_ext': build_ext},
    # ext_modules=cythonize(
    #     extensions,
    #     compiler_directives={
    #         'language_level': '3',
    #         'embedsignature': True
    #     },
    #     annotate=True
    # ),
    entry_points={
        'console_scripts': [
            'tu-addrs=traceutils.scripts.tu_addrs:main',
            'tu-adjs=traceutils.scripts.tu_adjs:main',
            'tu-pydig=traceutils.scripts.tu_pydig:main'
        ],
    },
    ext_modules=extensions,
    zip_safe=False,
    package_data=package_data,
    include_package_data=True,
    python_requires='>3.6'
)
