!function(exports){
  'use strict'
  // All javascript codes are called in smaller form from page. Normally used into page for
  // specific page-on-action, I prefer externalize this component for "one load" but a load when
  // the page is really showed (like images or any other page-content oriented component)
  // The behavor bellow should not reside in the application.js more suitable for 'reuse component'
  // or core components from your application
  function refresh_page(github_path){
    var githubmates = new GithubMatesServices()
    githubmates.get_contributors(github_path, function(contributors){
      var address     = new Address(google.maps)
      var addresslist = [],
          contribkeys = []
      contributors.forEach(function(user, key){
        if (user.location != '' && user.geocode == '') {
          addresslist.push  (user.location)
          contribkeys.push  (key)
        }
      })
      if (addresslist.length > 0) {
        address.search(addresslist, function(results){
          var contribkey
          results.forEach(function(location, key){
            contribkey = contribkeys[key]
            contributors[contribkey].geocode  = location.found > 0 ? location.latlng : 0
            contributors[contribkey].updated = true
          })
          githubmates.save_contributors(contributors, function(){
            console.log('Terminé')
          })
        })
      } else {
        console.log('Pas besoin de mise à jour')
        console.log(contributors)
      }
    })
  }
  
  if (!exports.pagejs) exports.pagejs = {}
  exports.pagejs.repodetails = {
    // Usage : pagejs.repodetails.refresh_page('github_path')
    refresh_page: refresh_page
  }
}(this)














      if (false) {
        function refresh_page(github_path){
          githubmates = new GithubMatesServices()
          pagemaps    = new PageMaps('maps','userfields')
          // -- Find all contributors with a location and get new coordinations
          githubmates.get_contributors(github_path, function(contributors){
            var address     = new Address(google.maps)
            var addresslist = [],
                contribkeys = []
            contributors.forEach(function(user, key){
              if (user.location != '' && user.latlng != 0) {
                addresslist.push  (user.localition)
                contribkeys.push  (key)
              }
            })
            if (addresslist.length > 0) {
              pagemaps.notify_update_geocodes(address) // -- Contient entre autre un timer
              address.search(addresslist, function(results){
                var contribkey
                results.forEach(function(location, key){
                  contribkey = contribkeys[key]
                  contributors[contribkey].latlng  = location.found > 0 ? location.latlng : 0
                  contributors[contribkey].updated = true
                })
                githubmates.save_contributors(contributors, function(){
                  pagemaps.show_maps(contributors)
                  contributors.forEach(function(user){
                    if (user.location != '' && user.latlng == 0) pagemaps.add_userfields(user)
                  })
                })
              })
            } else {
              pagemaps.show_maps(contributors)
            }
          })
        }
        refresh_page('ludovicdeluna/chartkick')
        // -- Find all projects for on user
        githubmates.get_projects('ludovicdeluna', function(projects){
          console.log(projects)
        })
      }
      
      
      if (false) {
        !function(){
          'use strict'
          var github_project = new GithubMatesServices('ludovicdeluna/chartkick')
          github_project.sync_geocodes(log)
          function log(results){
            console.log(results)
          }
        }
      }