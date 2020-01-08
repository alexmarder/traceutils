from Cython.Distutils import build_ext
from setuptools import setup, find_packages
from setuptools.extension import Extension
from Cython.Build import cythonize


# extensions_names = {
#     'traceutils.utils.utils': ['traceutils/utils/utils.pyx'],
#     'traceutils.utils.net': ['traceutils/utils/net.pyx'],
#     'traceutils.utils.dicts': ['traceutils/utils/dicts.pyx'],
#     'traceutils.file2': ['traceutils/file2/file2.pyx'],
#     'traceutils.as2org': ['traceutils/as2org/as2org.pyx'],
#     'traceutils.bgp': ['traceutils/bgp/bgp.pyx'],
#     'traceutils.bgpreader': ['traceutils/bgpreader/reader.pyx'],
#     'traceutils.radix.radix_prefix': ['traceutils/radix/radix_prefix.pyx'],
#     'traceutils.radix.radix_node': ['traceutils/radix/radix_node.pyx'],
#     'traceutils.radix.radix_tree': ['traceutils/radix/radix_tree.pyx'],
#     'traceutils.radix.radix': ['traceutils/radix/radix.pyx'],
#     'traceutils.radix.ip2as': ['traceutils/radix/ip2as.pyx'],
#     'traceutils.scamper.hop': ['traceutils/scamper/hop.pyx'],
#     'traceutils.scamper.atlas': ['traceutils/scamper/atlas.pyx'],
#     'traceutils.scamper.warts': ['traceutils/scamper/warts.pyx'],
#     'traceutils.scamper.pyatlas': ['scamper/py_atlas.py'],
#     'traceutils.progress': ['traceutils/progress/bar.py'],
#     # 'traceutils.traceparse': ['traceparse.py']
# }

extensions_names = {
    'traceutils.utils.utils': ['traceutils/utils/utils.pyx'],
    'traceutils.utils.net': ['traceutils/utils/net.pyx'],
    'traceutils.utils.dicts': ['traceutils/utils/dicts.pyx'],
    'traceutils.file2.file2': ['traceutils/file2/file2.pyx'],
    'traceutils.as2org.as2org': ['traceutils/as2org/as2org.pyx'],
    'traceutils.bgp.bgp': ['traceutils/bgp/bgp.pyx'],
    'traceutils.bgpreader.reader': ['traceutils/bgpreader/reader.pyx'],
    'traceutils.radix.radix_prefix': ['traceutils/radix/radix_prefix.pyx'],
    'traceutils.radix.radix_node': ['traceutils/radix/radix_node.pyx'],
    'traceutils.radix.radix_tree': ['traceutils/radix/radix_tree.pyx'],
    'traceutils.radix.radix': ['traceutils/radix/radix.pyx'],
    'traceutils.radix.ip2as': ['traceutils/radix/ip2as.pyx'],
    'traceutils.radix.ip2ases': ['traceutils/radix/ip2ases.pyx'],
    'traceutils.scamper.hop': ['traceutils/scamper/hop.pyx'],
    'traceutils.scamper.atlas': ['traceutils/scamper/atlas.pyx'],
    'traceutils.scamper.warts': ['traceutils/scamper/warts.pyx'],
    'traceutils.scamper.pyatlas': ['scamper/py_atlas.py'],
    'traceutils.progress.bar': ['traceutils/progress/bar.py'],
    # 'traceutils.traceparse': ['traceparse.py']
}

extensions = [Extension(k, v) for k, v in extensions_names.items()]
package_data = {k: ['*.pxd'] for k in extensions_names}

setup(
    name="traceutils",
    version='6.15.6',
    author='Alex Marder',
    description="Various packages for traceroute and BGP dump analysis.",
    url="https://github.com/alexmarder/traceutils",
    packages=find_packages(),
    install_requires=['ujson', 'cython'],
    cmdclass={'build_ext': build_ext},
    ext_modules=cythonize(
        extensions,
        compiler_directives={
            'language_level': '3',
            'embedsignature': True
        },
        annotate=True
    ),
    zip_safe=False,
    package_data=package_data,
    include_package_data=True,
    python_requires='>3.6'
)
