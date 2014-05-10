# Define class StormKeeper here

##
# SINGLETON CLASS OBJECT
instance = null
module.exports = (args) ->
    if not instance?
        instance = new StormKeeper args
    return instance
