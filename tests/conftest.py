import asyncio
import os
import pathlib
import sys

import pytest

from testsuite.daemons import service_client

# install it using `pip3 install ../third_party/testsuite/`
pytest_plugins = [
    'testsuite.pytest_plugin',
]

SERVICE_BASEURL = 'http://localhost:8080/'
ROOT_PATH = pathlib.Path(__file__).parent.parent


@pytest.fixture(scope="session")
def event_loop():
    return asyncio.get_event_loop()


@pytest.fixture
async def service_template_client(
        service_template_daemon,
        service_client_options,
        ensure_daemon_started,
        mockserver,
):
    await ensure_daemon_started(service_template_daemon)
    yield service_client.Client(SERVICE_BASEURL, **service_client_options)


def _copy_service_configs(
        *,
        service_name: str,
        destination: pathlib.Path,
        consfigs_path: pathlib.Path,
) -> None:
    path_suffixes = [
        'static_config.yaml',
        'dynamic_config_fallback.json',
        'config_vars.yaml',
        'secure_data.json',
    ]

    for path_suffix in path_suffixes:
        source_path = consfigs_path / path_suffix
        if not source_path.is_file():
            continue

        conf = source_path.read_text()
        conf = conf.replace('/etc/' + service_name, str(destination))
        conf = conf.replace('/var/cache/' + service_name, str(destination))
        conf = conf.replace('/var/log/' + service_name, str(destination))
        conf = conf.replace('/var/run/' + service_name, str(destination))
        (destination / path_suffix).write_text(conf)


@pytest.fixture(scope='session')
async def service_template_daemon(
        register_daemon_scope,
        service_spawner,
        mockserver_info,
        request,
        tmp_path_factory,
):
    build_dir = pathlib.Path(request.config.getoption('--build-dir')).resolve()
    service_name = 'service_template'
    consfigs_path = ROOT_PATH.joinpath('configs')
    temp_dir_name = tmp_path_factory.mktemp(service_name)
    print(f'{service_name} consfigs path: {consfigs_path}')
    print(f'{service_name} temp dir: {temp_dir_name}')

    _copy_service_configs(
        service_name=service_name,
        destination=temp_dir_name,
        consfigs_path=consfigs_path,
    )

    async with register_daemon_scope(
            name=service_name,
            spawn=service_spawner(
                [
                    str(build_dir.joinpath('service_template')),
                    '--config',
                    str(temp_dir_name.joinpath('static_config.yaml')),
                ],
                check_url=SERVICE_BASEURL + 'ping',
            ),
    ) as scope:
        yield scope
