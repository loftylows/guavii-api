{application,redix_pool,
             [{applications,[kernel,stdlib,elixir,logger,poolboy,redix]},
              {description,"Simple Redis pooling built on redix and poolboy"},
              {modules,['Elixir.RedixPool','Elixir.RedixPool.Config',
                        'Elixir.RedixPool.Worker']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.RedixPool',[]}}]}.
