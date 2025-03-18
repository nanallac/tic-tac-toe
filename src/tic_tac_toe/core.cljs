(ns tic-tac-toe.core
  (:require [replicant.dom :as r]
            [tic-tac-toe.game :as game]
            [tic-tac-toe.ui :as ui]))

(defn start-new-game [store]
  (reset! store (game/create-game {:size 3})))

(defn main []
  ;; set up the atom
  (let [store (atom nil)
        el (js/document.getElementById "app")]

    ;; globally handle dom events
    (r/set-dispatch!
     (fn [_ [action & args]]
       (case action
         :tic (apply swap! store game/tic args)
         :reset (start-new-game store))))

    ;; render on every change
    (add-watch store ::render
               (fn [_ _ _ game]
                 (->> (ui/game->ui-data game)
                      ui/render-game
                      (r/render el))))

    ;; trigger first render by initializing game
    (start-new-game store)))
