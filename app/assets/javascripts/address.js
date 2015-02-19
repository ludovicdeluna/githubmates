!function(exports){
  'use strict'
  /*
   * --
   * Find geocodes for a list of address with Google Maps (Geocoder API)
   * --
   * Language: Javascript 1.8.5
   * Deps    : Google Maps v3 Library
   * Usage   : address = new Address(google.maps)
   *           address.search(['Paris, France','London, UK'], function(results){ console.log(results) })
   *           results = an array of litteral objects :
   *           {
   *             address:  'First address found by Google Geocoder from Maps Database',
   *             latlng:   'Geocodes of this address for markers in Google Maps : (lat,lng)'
   *             searched: 'address given for search to Geocoder',
   *             found:    Number of places with similar names or 0 if nothing found
   *           }
   * Licence : MIT         (http://opensource.org/licenses/mit-license)
   * Author  : Copyright (c) 2014 - Ludovic de Luna (ludovic@deluna.fr)
   * Notice  : Keep the Licence, Author and this Notice unmodified with the code bellow for
   *           any reuse / distribution, except if this code is minified.
   */

  function Address(maps, addresslist){
    if (maps && typeof maps.Geocoder == 'function') {
      this.geocoder     = new maps.Geocoder()
      this.geocoder_ok  = maps.GeocoderStatus.OK
    } else {
      this.geocoder = this.geocoder_ok = null
    }
    this.addresslist    = null
    this.results        = []
    this.when_done      = null
    this.progress_done  = 0
    this.pgoress_total  = 0
    if (!(this.geocoder && this.geocoder_ok)) {
      throw 'new Address(service: google.maps)'
    }
  }

  Address.prototype.search = function(addresslist, callback){
    if (this.when_done) {
      console.log(WARN_RUNNING)
      return false
    } else if (!addresslist || typeof callback != 'function') {
      console.log ('Address.search( address_list: [], callback: function([{searched,address,latlng,found}]) )')
      return false
    }          
    if (typeof addresslist == 'string') addresslist = [addresslist]
    this.addresslist    = addresslist
    this.results        = []
    this.when_done      = callback
    this.progress_done  = 0
    this.progress_total = this.addresslist.length
    Address_each.bind(this).call()
    return true
  }

  Address.prototype.find_address = function(address, callback){
    if (callback && this.when_done) {
      console.log(WARN_RUNNING)
      return false
    } else if (!address || !this.when_done && !callback) {
      console.log('Address.find_address( address: string, callback: function({searched,address,latlng,found}) )')
      return false
    }
    // Returns control to the code immediatly after a call
    this.geocoder.geocode ({address: address}, function(results, status){
      var address_result = {searched: address, address: "", latlng: "", found: 0}
      if (status == this.geocoder_ok) {
        address_result = {
          searched: address,
          address:  results[0].formatted_address,
          latlng:   results[0].geometry.location.toString(),
          found:    results.length // Geocoder may return more than one result if ambiguous address
        }
      }
      if (this.when_done) {
        this.progress_done++
        Address_each.bind(this,address_result).call()
      } else {
        callback(address_result)
      }
    }.bind(this))
    return true
  }

  // -- Private
  var WARN_RUNNING = 'Warning: You have already a search in progress. Request ignored'

  function Address_each(result){
    if (result) this.results.push(result)
    if (this.addresslist.length >= 1 ) {
      this.find_address (this.addresslist.shift())
    } else {
      var callback    = this.when_done
      this.when_done  = null
      callback(this.results)
    }
  }

  exports.Address = Address
}(this)