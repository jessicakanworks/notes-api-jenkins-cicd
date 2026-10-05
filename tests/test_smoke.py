def test_import():
    import importlib
    assert importlib.util.find_spec("flask") is not None
