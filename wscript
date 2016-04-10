"""
Custom build file for UV Alert Pebble client.
"""

import json
import os
import re
import shutil
import subprocess

from waflib.Configure import conf

execfile('pebblejs/wscript')


def options(ctx):
    ctx.load('pebble_sdk')

    ctx.load('aplite_legacy', tooldir='pebblejs/waftools')
    ctx.load('configure_appinfo', tooldir='pebblejs/waftools')
    ctx.load('pebble_sdk_version', tooldir='pebblejs/waftools')


@conf
def concat_javascript(ctx, js_path=None):
    webpack_output = js_path + '/app.js'

    # Set path to Node.js binaries
    node_path = subprocess.check_output(['npm', 'bin']).decode().strip()
    os.environ['PATH'] = node_path + ':' + os.environ.get('PATH')

    # Webpack doesn't indicate success with exit code
    # https://github.com/webpack/webpack/issues/708
    # Remove its output file to fail the build instead
    try:
        os.unlink(webpack_output)
    except OSError:
        pass

    subprocess.check_call(['webpack', '--optimize', '--bail'])

    def copy_output(task):
        shutil.copyfile(webpack_output, task.outputs[0].abspath())

    js_target = ctx.path.make_node('build/src/js/pebble-js-app.js')

    ctx(rule=copy_output,
        source=[webpack_output],
        target=js_target)

    return js_target

# vim:filetype=python
