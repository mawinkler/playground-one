# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
import werkzeug
import glob
werkzeug.cached_property = werkzeug.utils.cached_property
from flask import Flask, request, url_for
from flask_restx import Api, Resource, fields
from flask_cors import CORS
import requests
import os
import logging
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware
xray_recorder.configure(context_missing='LOG_ERROR')
from aws_xray_sdk.core import patch_all

patch_all()

flask_app = Flask(__name__)

log_level = logging.INFO
flask_app.logger.setLevel(log_level)
# enable CORS
CORS(flask_app, resources={r'/*': {'origins': '*'}})

#configure SDK code
xray_recorder.configure(service='Product-Catalog')
XRayMiddleware(flask_app, xray_recorder)

AGG_APP_URL = os.environ.get("AGG_APP_URL")

if AGG_APP_URL is None:
    AGG_APP_URL="http://localhost:3000/catalogDetail"

flask_app.logger.info('AGG_APP_URL is ' + str(AGG_APP_URL))

filepath = os.path.join('/products', 'products.txt')

# Fix of returning swagger.json on HTTP
@property
def specs_url(self):
    """
    The Swagger specifications absolute url (ie. `swagger.json`)

    :rtype: str
    """
    return url_for(self.endpoint('specs'), _external=False)

Api.specs_url = specs_url
app = Api(app = flask_app,
          version = "1.0",
          title = "Product Catalog",
          description = "Complete dictionary of Products available in the Product Catalog")

name_space = app.namespace('products', description='Products from Product Catalog')

model = app.model('Name Model',
                  {'name': fields.String(required = True,
                                         description="Name of the Product",
                                         help="Product Name cannot be blank.")})

list_of_names = {}
    
def read_file():
    flask_app.logger.info(filepath)
    if not os.path.exists(filepath):
        open(filepath, 'w').close()
    else:
        with open(filepath, "r") as f:
            for line in f:
               (key, val) = line.split()
               list_of_names[int(key)] = val
  
@name_space.route('/')
class Products(Resource):
    """
    Manipulations with products.
    """
    def get(self):
        """
        List of products.
        Returns a list of products
        """
        try:
            read_file()
            flask_app.logger.info('AGG_APP_URL is ' + str(AGG_APP_URL))
            response = requests.get(str(AGG_APP_URL))
            content = response.json()
            flask_app.logger.info('Get-All Request succeeded')
            return {
                "products": list_of_names,
                "details" : content
            }
        except KeyError as e:
            flask_app.logger.error('Error 500 Could not retrieve information ' + e.__doc__ )
            name_space.abort(500, e.__doc__, status = "Could not retrieve information", statusCode = "500")
        except Exception as e:
            flask_app.logger.error('Error 400 Could not retrieve information ' + e.__doc__ )
            name_space.abort(400, e.__doc__, status = "Could not retrieve information", statusCode = "400")

@name_space.route('/ping')
class Ping(Resource):
    def get(self):
        return "healthy"

@name_space.route("/<int:id>")
@name_space.param('id', 'Specify the ProductId')
class MainClass(Resource):

    @app.doc(responses={ 200: 'OK', 400: 'Invalid Argument', 500: 'Mapping Key Error' })
    def get(self, id=None):
        try:
            name = list_of_names[id]
            flask_app.logger.info('AGG_APP_URL is ' + str(AGG_APP_URL))
            response = requests.get(str(AGG_APP_URL))
            content = response.json()
            flask_app.logger.info('Get Request succeeded ' + list_of_names[id])
            return {
                "status": "Product Details retrieved",
                "name" : list_of_names[id],
                "details" : content['details']
            }
        except KeyError as e:
            flask_app.logger.error('Error 500 Could not retrieve information ' + e.__doc__ )
            name_space.abort(500, e.__doc__, status = "Could not retrieve information", statusCode = "500")
        except Exception as e:
            flask_app.logger.error('Error 400 Could not retrieve information ' + e.__doc__ )
            name_space.abort(400, e.__doc__, status = "Could not retrieve information", statusCode = "400")


    @app.doc(responses={ 200: 'OK', 400: 'Invalid Argument', 500: 'Mapping Key Error' })
    @app.expect(model)
    def post(self, id):
        try:
            f = open(filepath, "a")
            flask_app.logger.info(id, request.json['name'])
            f.write('{} {}'.format(id, request.json['name']))
            f.write('\n')
            list_of_names[id] = request.json['name']
            flask_app.logger.info('Post Request succeeded ' + list_of_names[id])
            return {
                "status": "New Product added to Product Catalog",
                "name": list_of_names[id]
            }
        except KeyError as e:
            flask_app.logger.error('Error 500 Could not retrieve information ' + e.__doc__ )
            name_space.abort(500, e.__doc__, status = "Could not save information", statusCode = "500")
        except Exception as e:
            flask_app.logger.error('Error 400 Could not retrieve information ' + e.__doc__ )
            name_space.abort(400, e.__doc__, status = "Could not save information", statusCode = "400")

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)