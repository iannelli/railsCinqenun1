class ApplicationController < ActionController::Base
    protect_from_forgery
    
    # factures_controller ---
    include AnnulFactureAcompte
    include CreateFactureAcompte
    include UpdateFactureAcompte
    include MajNumrangProjet
    include UpdateParametreNumfact
    include UpdateFactureTacperiode
    include UpdateTacheTacperiode
    include VerifPresenceDoublon
    
    # paramuns_controller ---
    include GetEcritureInitialePositive
    include IndexChangementAnnee
    include ProjetArchivageCondition
    include ProjetArchivageFacture
    include ProjetArchivageProjet
    include ProjetArchivageTache
    include ProjetInactifDepassSeuil
    include ProjetStatutFacture
    include ProjetStatutTache
    include StatSuiviImpayeeProjetca
    include StatSuiviInit

    # projetolds_controller ---
    include ArchivageFactureCreate
    include ArchivageTacheCreate
    include ReactivationFactureCreate
    include ReactivationTacheCreate

end
