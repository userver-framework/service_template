import pytest

pytest_plugins = [
    'pytest_userver.plugins.mongo',
]


@pytest.fixture(scope='session')
def pgsql_local(service_source_dir, create_mongo_service):
    """Create schemas databases for tests"""
    databases = discover.find_schemas(
        'mongo_grpc_service_template',
        [service_source_dir.joinpath('postgresql/schemas')],
    )
    return create_mongo_service(list(databases.values()))
