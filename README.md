# README

#### API using CARTO as a backend

Things you may want to cover:

* Ruby version:  2.4.9
* Rails version: 5.0.7.2
* How to run the test suite

```sh
bundle exec rspec
```

* Deployment instructions

```sh
git clone repository
cd repository 
bundle install
rails s
```

* Production deployment
  - Application deployed in heroku. The application can be consulted at https://airquality-app-reino.herokuapp.com/
  - Example of usage:

```sh
curl --location --request GET 'https://airquality-app-reino.herokuapp.com/api/v2/timeseries?variables[]=o3&variables[]=so2&step=hour&time_min=2016-10-02T01:45:00Z&time_max=2016-10-10T01:45:00Z&stations[]=aq_jaen'
```
