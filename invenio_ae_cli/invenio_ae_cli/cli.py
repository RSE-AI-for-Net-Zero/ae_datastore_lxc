import click
from invenio_cli.cli.install import install
from invenio_cli.cli.cli import init

@click.group()
def cli():
    pass

cli.add_command(install)
cli.add_command(init)
