import pathlib

import pytest

from testsuite.daemons import service_client

# install it using `pip3 install yandex-taxi-testsuite`
pytest_plugins = [
    'testsuite.pytest_plugin',
]

SERVICE_NAME = 'service_template'
SERVICE_BASEURL = 'http://localhost:8080/'
ROOT_PATH = pathlib.Path(__file__).parent.parent


def pytest_addoption(parser) -> None:
    group = parser.getgroup('userver')
    group.addoption(
        '--build-dir',
        default=pathlib.Path.cwd() / '../build',
        type=pathlib.Path,
        help='Path to uservice build directory.',
    )


@pytest.fixture
async def service_template_client(
        service_template_daemon,
        service_client_options,
        ensure_daemon_started,
        mockserver,
):
    await ensure_daemon_started(service_template_daemon)
    return service_client.Client(SERVICE_BASEURL, **service_client_options)


@pytest.fixture(scope='session')
def build_dir(request) -> pathlib.Path:
    return pathlib.Path(request.config.getoption('--build-dir')).resolve()


@pytest.fixture(scope='session')
async def service_template_daemon(
        create_daemon_scope,
        tmp_path_factory,
        build_dir,
):
    configs_path = ROOT_PATH.joinpath('configs')
    temp_dir_name = tmp_path_factory.mktemp(SERVICE_NAME)

    _copy_service_configs(
        service_name=SERVICE_NAME,
        destination=temp_dir_name,
        configs_path=configs_path,
    )

    async with create_daemon_scope(
            args=[
                str(build_dir.joinpath('service_template')),
                '--config',
                str(temp_dir_name.joinpath('static_config.yaml')),
            ],
            check_url=SERVICE_BASEURL + 'ping',
    ) as scope:
        yield scope


def _copy_service_configs(
        *,
        service_name: str,
        destination: pathlib.Path,
        configs_path: pathlib.Path,
) -> None:
    path_suffixes = [
        'static_config.yaml',
        'dynamic_config_fallback.json',
        'config_vars.yaml',
        'secure_data.json',
    ]

    for path_suffix in path_suffixes:
        source_path = configs_path / path_suffix
        if not source_path.is_file():
            continue

        conf = source_path.read_text()
        conf = conf.replace('/etc/' + service_name, str(destination))
        conf = conf.replace('/var/cache/' + service_name, str(destination))
        conf = conf.replace('/var/log/' + service_name, str(destination))
        conf = conf.replace('/var/run/' + service_name, str(destination))
        (destination / path_suffix).write_text(conf)
