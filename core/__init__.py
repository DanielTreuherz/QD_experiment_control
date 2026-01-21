import inspect 

devices = {}    # { "SDG1": <instance>, "Scope1": <instance> }


def get_public_commands(instance):
    """
    Introspects an object instance and returns a dictionary of its
    public methods, suitable for a command dispatcher.

    A 'public method' is one that does not start with an underscore '_'.
    """
    commands = {}
    for name, method in inspect.getmembers(instance, predicate=inspect.ismethod):
        if not name.startswith('_'):
            commands[name] = method
    return commands

def register_device(name, instance):
    idn = instance.ask('*IDN?')
    print(f'Succesfully connected to {idn} \nRegistered {name} as an instance of {instance.__class__.__name__}\n')
    devices[name] = instance
    