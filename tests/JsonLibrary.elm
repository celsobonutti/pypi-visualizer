module JsonLibrary exposing (..)


valid : String
valid =
    """{
        "info": {
            "project_urls": {
                "Documentation": "https://requests.readthedocs.io/",
                "Homepage": "https://requests.readthedocs.io/",
                "Source": "https://github.com/psf/requests"
            },
            "requires_dist": [
                "chardet (<5,>=3.0.2)",
                "idna (<3,>=2.5)"
            ]
        },
        "releases": {
            "0.1": [],
            "0.2": [],
            "0.3": []
        }
    }"""


validWithoutDependencies : String
validWithoutDependencies =
    """{
        "info": {
            "project_urls": {
                "Documentation": "https://requests.readthedocs.io/",
                "Homepage": "https://requests.readthedocs.io/",
                "Source": "https://github.com/psf/requests"
            },
            "requires_dist": null
        },
        "releases": {
            "0.1": [],
            "0.2": [],
            "0.3": []
        }
    }"""


invalid : String
invalid =
    """{
        "info": {
            "proect_urls": {
                "Documentation": "https://requests.readthedocs.io/",
                "Homepage": "https://requests.readthedocs.io/",
                "Source": "https://github.com/psf/requests"
            },
            "requirs_dist": null
        },
        "releas": {
            "0.1": [],
            "0.2": [],
            "0.3": []
        }
    }"""
