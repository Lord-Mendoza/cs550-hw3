import os
import codecs
from setuptools import setup, find_packages


def read(rel_path):
    here = os.path.abspath(os.path.dirname(__file__))
    with codecs.open(os.path.join(here, rel_path), 'r') as fp:
        return fp.read()


def get_version(rel_path):
    for line in read(rel_path).splitlines():
        if line.startswith('__version__'):
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    else:
        raise RuntimeError("Unable to find version string.")


setup(
    name='db-grader',
    version='1.0',
    author='Sulabh Shrestha',
    author_email='sshres2@gmu.edu',
    description='Database query graders',
    long_description='Auto-grader for sql queries',
    url='https://github.com/sulabh-shr/sqlgrader.git',
    packages=find_packages(),
    install_requires=['mysql-connector-python', 'natsort'],
    python_requires='>=3.7',
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
    ]
)