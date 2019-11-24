class ApplicationController < ActionController::Base
    protect_from_forgery
    
    # paramuns_controller ---
    include IndexChangementAnnee
    include ProjetStatutTache
    include ProjetStatutFacture
    include ProjetArchivageCondition
    include ProjetArchivageProjet
    include ProjetArchivageTache
    include ProjetArchivageFacture
    include ProjetInactifDepassSeuil
    include StatSuiviInit
    include StatSuiviFactureimpayee
    
    # factures_controller ---
    include VerifPresenceDoublon
    include UpdateParametreNumfact
    include UpdateTacfacString
    include CreateFactureAcompte
    include AnnulFactureAcompte
    include MajPeriodeTache
    include MajNumrangProjet
    
    # projetolds_controller ---
    include ArchivageTacheCreate
    include ArchivageFactureCreate
    include ReactivationTacheCreate
    include ReactivationFactureCreate
    
    # recettes_controller ---
    include LignetvaCreateUpdate
    
    # depenses_controller ---
    include DepenseLignetvaCreate
    include DepenseLignetvaUpdate
    
    # immobs_controller ---
    include ImmobLignetvaCreate
    include ImmobLignetvaUpdate
    include ImmobIndiceMillesime

end
