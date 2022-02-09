# Start via:
# ~/.local/bin/pytest --build-dir=/data/code/service_template/build_debug


async def test_basic(service_template_client):
    response = await service_template_client.post('/hello', json={})
    assert response.status == 200
