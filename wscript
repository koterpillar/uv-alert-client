"""
Custom build file for UV Alert Pebble client.
"""

import json
import os
import re
import shutil

from waflib.Configure import conf

top = '.'
out = 'build'

execfile('pebblejs/wscript')


def options(ctx):
    ctx.load('pebble_sdk')

    ctx.load('aplite_legacy', tooldir='pebblejs/waftools')
    ctx.load('configure_appinfo', tooldir='pebblejs/waftools')
    ctx.load('pebble_sdk_version', tooldir='pebblejs/waftools')


@conf
def concat_javascript(ctx, js_path=None):
    js_nodes = [js_path + '/app.js']

    def concat_javascript_task(task):
        shutil.copyfile(js_nodes[0], task.outputs[0].abspath())

    js_target = ctx.path.make_node('build/src/js/pebble-js-app.js')

    ctx(rule=concat_javascript_task,
        source=js_nodes,
        target=js_target)

    return js_target

# vim:filetype=python
