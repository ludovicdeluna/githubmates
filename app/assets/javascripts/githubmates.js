!function(exports){
  'user strict'
  function GithubMatesServices(){}

  GithubMatesServices.prototype.get_contributors = function(github_path, callback){
    if (typeof callback != 'function' || !github_path) {
      console.log ("Usage : GithubMatesServices.get_contributors(github_path: 'user/project', callback: functon)")
      return false
    }
    xhr.onreadystatechange = function(){
      if (xhr.readyState == xhr.DONE && xhr.status == 200) {
        var response      = JSON.parse(xhr.responseText)
        var contributors  = response.repo ? response.repo.users : []
        callback(contributors)
      }
    }
    xhr.open('GET','/repos/'+github_path+'.json',true)
    // -- FIX : Update controller to accept this parameter to filter only contributors with location filled in
    xhr.send('with_location=true')
    return true
  }

  GithubMatesServices.prototype.save_contributors = function(contributors, callback){
    if (typeof callback != 'function' || !(contributors instanceof Array)) {
      console.log ("Usage : GithubMatesServices.save_contributors(contributors: [], callback: functon)")
      return false
    }
    var upd_contributors = []
    contributors.forEach (function(contributor){
      if (contributor.updated) upd_contributors.push(contributor)
    })
    if (upd_contributors.length > 0) {
      xhr.onreadystatechange = function(){
        if (xhr.readyState == xhr.DONE && xhr.status == 200) callback()
      }
      // -- FIX : Update routes to use only one path : /users
      xhr.open('POST','/repos/ludovic/chartkick/geoloc.json')
      xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
      xhr.send(JSON.stringify ({users: upd_contributors}))
    } else callback()
    return true
  }

  // -- Private and Common
  var xhr = new XMLHttpRequest()

  exports.GithubMatesServices = GithubMatesServices
}(this)