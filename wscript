"""
Custom build file for UV Alert Pebble client.
"""

import json
import os
import re

from waflib.Configure import conf

top = '.'
out = 'build'

execfile('pebblejs/wscript')

VENDOR_JS_PATH = 'pebblejs/src/js'


def options(ctx):
    ctx.load('pebble_sdk')

    ctx.load('aplite_legacy', tooldir='pebblejs/waftools')
    ctx.load('configure_appinfo', tooldir='pebblejs/waftools')
    ctx.load('pebble_sdk_version', tooldir='pebblejs/waftools')


@conf
def concat_javascript(ctx, js_path=None):
    js_nodes = sum(
        (
            ctx.path.ant_glob('{}/**/*.{}'.format(path, ext))
            for path in (js_path, VENDOR_JS_PATH)
            for ext in ('js', 'json')
        ),
        []
    )

    if not js_nodes:
        return []

    def concat_javascript_task(task):
        LOADER_PATH = "loader.js"
        LOADER_TEMPLATE = ("__loader.define({relpath}, {lineno}, " +
                           "function(exports, module, require) {{\n{body}\n}});")
        JSON_TEMPLATE = "module.exports = {body};"
        APPINFO_PATH = "appinfo.json"

        def loader_translate(source, lineno):
            return LOADER_TEMPLATE.format(
                relpath=json.dumps(source['relpath']),
                lineno=lineno,
                body=source['body'])

        sources = []
        seen_paths = set()
        for node in task.inputs:
            abspath = node.abspath()
            if abspath.startswith(os.path.abspath(VENDOR_JS_PATH)):
                relpath = os.path.relpath(abspath, VENDOR_JS_PATH)
            else:
                relpath = os.path.relpath(abspath, js_path)

            if relpath in seen_paths:
                continue
            seen_paths.add(relpath)

            with open(abspath, 'r') as f:
                body = f.read()
                if relpath.endswith('.json'):
                    body = JSON_TEMPLATE.format(body=body)

                if relpath == LOADER_PATH:
                    sources.insert(0, body)
                else:
                    sources.append({'relpath': relpath, 'body': body})

        with open(APPINFO_PATH, 'r') as f:
            body = JSON_TEMPLATE.format(body=f.read())
            sources.append({'relpath': APPINFO_PATH, 'body': body})

        sources.append('__loader.require("main");')

        with open(task.outputs[0].abspath(), 'w') as f:
            lineno = 1
            for source in sources:
                if type(source) is dict:
                    body = loader_translate(source, lineno)
                else:
                    body = source
                f.write(body + '\n')
                lineno += body.count('\n') + 1

    js_target = ctx.path.make_node('build/src/js/pebble-js-app.js')

    ctx(rule=concat_javascript_task,
        source=js_nodes,
        target=js_target)

    return js_target

# vim:filetype=python
