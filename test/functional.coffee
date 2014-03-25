dynmod = require '../coffee/dynmod'


console.log 's1', dynmod 'anybase', 'anybase@0.1.0'
console.log 's2', dynmod.remove 'anybase'
console.log 's3', dynmod.install 'anybase'
console.log 's4', dynmod.current 'anybase', 'sync-exec'
console.log 's5', dynmod.list()
console.log 's6', dynmod.list 'anybase'
console.log 's7', dynmod.list 'anybase', 'sync-exec'


dynmod 'anybase', 'anybase@0.1.0', (args...) ->
  console.log 'a1', args
  dynmod.remove 'anybase', (args...) ->
    console.log 'a2', args
    dynmod.install 'anybase', (args...) ->
      console.log 'a3', args
      dynmod.current 'anybase', 'sync-exec', (args...) ->
        console.log 'a4', args
        dynmod.list (args...) ->
          console.log 'a5', args
          dynmod.list 'anybase', (args...) ->
            console.log 'a6', args
            dynmod.list 'anybase', 'sync-exec', (args...) ->
              console.log 'a7', args
              dynmod.remove 'anybase', (args...) ->
                console.log 'a8', args
                console.log 'done'
