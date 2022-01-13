#!/usr/bin/env python
import os
import sys
import re

# require python 3.7 or newer
if sys.version_info < (3, 7):
    print('Error: dbt does not support this version of Python.')
    print('Please upgrade to Python 3.7 or higher.')
    sys.exit(1)


from setuptools import setup
try:
    from setuptools import find_namespace_packages
except ImportError:
    # the user has a downlevel version of setuptools.
    print('Error: dbt requires setuptools v40.1.0 or higher.')
    print('Please upgrade setuptools with "pip install --upgrade setuptools" '
          'and try again')
    sys.exit(1)

this_directory = os.path.abspath(os.path.dirname(__file__))
def _get_plugin_version_dict():
    _version_path = os.path.join(
        this_directory, 'dbt', 'adapters', 'greenplum', '__version__.py'
    )
    _semver = r'''(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)'''
    _pre = r'''((?P<prekind>a|b|rc)(?P<pre>\d+))?'''
    _version_pattern = fr'''version\s*=\s*["']{_semver}{_pre}["']'''
    with open(_version_path) as f:
        match = re.search(_version_pattern, f.read().strip())
        if match is None:
            raise ValueError(f'invalid version at {_version_path}')
        return match.groupdict()


# require a compatible minor version (~=), prerelease if this is a prerelease
def _get_dbt_core_version():
    parts = _get_plugin_version_dict()
    minor = "{major}.{minor}.0".format(**parts)
    pre = (parts["prekind"]+"1" if parts["prekind"] else "")
    return f"{minor}{pre}"

package_name = "dbt-greenplum"
package_version = "1.0.0"
dbt_core_version = _get_dbt_core_version()
description = """The greenplum adapter plugin for dbt"""

setup(
    name=package_name,
    version=package_version,
    description=description,
    long_description=description,
    author='dmitry.naumov',
    packages=find_namespace_packages(include=['dbt', 'dbt.*']),
    include_package_data=True,
    python_requires=">=3.6",
    install_requires=[
        "dbt-core~={}".format(dbt_core_version)
    ]
)
