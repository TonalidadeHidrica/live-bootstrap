#!/usr/bin/env python3
"""
This file contains a few functions to be shared by all Sys* classes
"""

# SPDX-FileCopyrightText: 2022 Dor Askayo <dor.askayo@gmail.com>
# SPDX-FileCopyrightText: 2021-22 fosslinux <fosslinux@aussies.space>
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-License-Identifier: GPL-3.0-or-later

import os
import shutil
import hashlib
import glob
import subprocess

import requests

from lib.utils import mount, umount

class SysGeneral:
    """
    A class from which all Sys* class are extended.
    Contains functions used in all Sys*
    """

    # All of these are variables defined in the individual Sys* classes
    preserve_tmp = None
    tmp_dir = None
    cache_dir = None
    base_dir = None
    git_dir = None
    sys_dir = None
    initramfs_path = None
    mounted_tmpfs = False

    def __del__(self):
        if not self.preserve_tmp:
            self.remove_tmp()

    def remove_tmp(self):
        """Remove the tmp directory"""
        if self.tmp_dir is None:
            return

        if self.mounted_tmpfs:
            print(f"Unmounting tmpfs from {self.tmp_dir}")
            umount(self.tmp_dir)

        print(f"Removing {self.tmp_dir}")
        shutil.rmtree(self.tmp_dir, ignore_errors=True)

    def mount_tmpfs(self):
        """Mount the tmpfs for this sysx"""
        if not os.path.isdir(self.tmp_dir):
            os.mkdir(self.tmp_dir)
        print(f"Mounting tmpfs on {self.tmp_dir}")
        mount('tmpfs', self.tmp_dir, 'tmpfs', 'size=8G')
        self.mounted_tmpfs = True

    def check_file(self, file_name):
        """Check hash of downloaded source file."""
        checksum_store = os.path.join(self.sys_dir, 'SHA256SUMS.sources')
        with open(checksum_store, encoding="utf_8") as checksum_file:
            hashes = checksum_file.read().splitlines()
        for hash_line in hashes:
            if os.path.basename(file_name) in hash_line:
                # Hash is in store, check it
                expected_hash = hash_line.split()[0]

                with open(file_name, "rb") as downloaded_file:
                    downloaded_content = downloaded_file.read() # read entire file as bytes
                readable_hash = hashlib.sha256(downloaded_content).hexdigest()
                if expected_hash == readable_hash:
                    return
                raise Exception(f"Checksum mismatch for file {os.path.basename(file_name)}:\n\
expected: {expected_hash}\n\
actual:   {readable_hash}\n\
When in doubt, try deleting the file in question -- it will be downloaded again when running \
this script the next time")

        raise Exception("File checksum is not yet recorded")

    def download_file(self, url, file_name=None):
        """
        Download a single source archive.
        """
        # Automatically determine file name based on URL.
        if file_name is None:
            file_name = os.path.basename(url)
        abs_file_name = os.path.join(self.cache_dir, file_name)

        # Create a cache directory for downloaded sources
        if not os.path.isdir(self.cache_dir):
            os.mkdir(self.cache_dir)

        # Actually download the file
        headers = {
                "Accept-Encoding": "identity"
        }
        if not os.path.isfile(abs_file_name):
            print(f"Downloading: {file_name}")
            response = requests.get(url, allow_redirects=True, stream=True,
                    headers=headers)
            if response.status_code == 200:
                with open(abs_file_name, 'wb') as target_file:
                    target_file.write(response.raw.read())
            else:
                raise Exception("Download failed.")

        # Check SHA256 hash
        self.check_file(abs_file_name)
        return abs_file_name

    def get_file(self, url, output=None):
        """
        Download and prepare source packages

        url can be either:
          1. a single URL
          2. list of URLs to download. In this case the first URL is the primary URL
             from which we derive the name of package directory
        output can be used to override file name of the downloaded file(s).
        """
        # Single URL
        if isinstance(url, str):
            assert output is None or isinstance(output, str)
            urls = [url]
            outputs = [output]
        # Multiple URLs
        elif isinstance(url, list):
            assert output is None or len(output) == len(url)
            urls = url
            outputs = output if output is not None else [None] * len(url)
        else:
            raise TypeError("url must be either a string or a list of strings")
        # Install base files
        for i, uri in enumerate(urls):
            # Download files into cache directory
            self.download_file(uri, outputs[i])

    def make_initramfs(self):
        """Package binary bootstrap seeds and sources into initramfs."""
        self.initramfs_path = os.path.join(self.tmp_dir, 'initramfs')

        # Create a list of files to go within the initramfs
        file_list = glob.glob(os.path.join(self.tmp_dir, '**'), recursive=True)

        # Use built-in removeprefix once we can use Python 3.9
        def remove_prefix(text, prefix):
            if text.startswith(prefix):
                return text[len(prefix):]
            return text  # or whatever

        file_list = [remove_prefix(f, self.tmp_dir + os.sep) for f in file_list]

        # Create the initramfs
        with open(self.initramfs_path, "w", encoding="utf_8") as initramfs:
            # pylint: disable=consider-using-with
            cpio = subprocess.Popen(
                    ["cpio", "--format", "newc", "--create",
                        "--directory", self.tmp_dir],
                     stdin=subprocess.PIPE, stdout=initramfs)
            cpio.communicate(input='\n'.join(file_list).encode())

stage0_arch_map = {
    "amd64": "AMD64",
}
