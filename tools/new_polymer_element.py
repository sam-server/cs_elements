import os
import re
import sys

# Matches the hyphen and the immediately following character
HYPHEN_NEXT_CHAR_RE = re.compile(r'-(.)')

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def lower_with_underscores(lower_with_hyphens):
    return lower_with_hyphens.replace('-', '_')


def upper_camel_case(lower_with_hyphens):
    result = ""
    pos = 0
    for match in HYPHEN_NEXT_CHAR_RE.finditer(lower_with_hyphens):
        result += lower_with_hyphens[pos:match.start()]
        result += match.group(1).upper()
        pos = match.end()
    if pos == 0:
        raise ValueError(
            'Polymer element requires at least one hyphen (\'-\') in name')
    result += lower_with_hyphens[pos:]
    return result[0].upper() + result[1:]


def path_components(location):
    head = location
    cs = []
    while head != '':
        head, tail = os.path.split(head)
        cs.append(tail)
    return cs


def rel_path_to_polymer(location):
    """
    Returns the relative path to the polymer package from the given location,
    a relative path to the root of the cs_elements package with no '..'
    components
    """
    import_depth = 1 + len(path_components(location))
    return os.path.join(
        os.path.join(* (['..'] * import_depth)),
        'packages/polymer/polymer.html'
    )


def check_valid_location(location):
    err = None
    if location.startswith('/'):
        err = 'Location must be a path relative to {0}'.format(PROJECT_ROOT)
    if any(map(lambda c: c in {'.', '..'}, path_components(location))):
        err = (
            'No element of the path can be a reference '
            'to the current directory (\'.\')'
            'or the parent directory (\'..\')'
        )
    if not os.path.isdir(location):
        print('Not a directory: {0}'.format(location))
    if err is not None:
        print(err)
        sys.exit(1)


def check_valid_name(name):
    if not re.match(r'^([a-z]+-)+[a-z]+$', name):
        print('polymer element name must be a string of lower case characters '
              'and contain at least one hyphen')
        sys.exit(1)


def write_dart_file(location, name):
    path = os.path.join(location, lower_with_underscores(name) + '.dart')
    template = '''
library cs_elements.<insert_lib_name>;

import 'package:polymer/polymer.dart';

@CustomTag('{name}')
class {classname} extends PolymerElement {{
  {classname}.created(): super.created();

  @override
  void attached() {{
    super.attached();
  }}

  @override
  void detached() {{
    super.detached();
  }}
}}
'''
    with open(path, 'w+') as f:
        f.write(template.format(
            name=name,
            classname=upper_camel_case(name)
        ))


def write_html_file(location, name):
    html_path = os.path.join(location, lower_with_underscores(name) + '.html')
    template = '''
<!DOCTYPE html>

<link rel="import" href="{polymer_import_path}">

<polymer-element name="{name}">
<template>
<style>
</style>
</template>
<script type="application/dart" src="{dart_script}"></script>
</polymer-element>
'''
    with open(html_path, 'w+') as f:
        f.write(template.format(
            name=name,
            polymer_import_path=rel_path_to_polymer(location),
            dart_script='{0}.dart'.format(lower_with_underscores(name))
        ))


def main(location, name='custom-element'):
    """
    Create a new polymer.dart element in the given folder

    arguments:
    - location: The location, relative to the cs_elements 'lib' directory in which to create the element
    - name: The name of the element, as a 'lower-with-hyphens' value.
    """

    os.chdir(PROJECT_ROOT)
    check_valid_location(location)
    check_valid_name(name)
    write_dart_file(location, name)
    write_html_file(location, name)

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) < 2:
        print('Usage: new_polymer_element.py location name\n')
        print('\tlocation: The location (relative to the cs_elements project root)')
        sys.exit(1)
    main(*args)


