(let [{: build} (require :hotpot.api.make)]
  (build :./fnl {:force? true :atomic? true} "./fnl/(.+)"
         (fn [path {: join-path}]
           (join-path :./lua path)))
  nil)
