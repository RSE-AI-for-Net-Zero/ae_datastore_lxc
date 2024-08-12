from invenio_cli.helpers.process import ProcessResponse, run_cmd, run_interactive

class LXCHelper(object):
    def __init__(self, project_shortname, local=True, log_config=None):
        pass
    
    def build_images(self, pull=False, cache=True):
        raise NotImplementedError

    def start_containers(self, app_only=False):
        raise NotImplementedError

    def build_images(self, pull=False, cache=True):
        raise NotImplementedError

    def stop_containers(self):
        raise NotImplementedError

    def destroy_containers(self):
        raise NotImplementedError

    def execute_cli_command(self, project_shortname, command):
        raise NotImplementedError


'''

'''
