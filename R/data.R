#' List of Nuclease objects representing common restriction enzymes
#'
#' List of Nuclease objects representing common restriction enzymes
#'     from REBASE database. 
#' 
#' @format List of Nuclease objects. 
#' 
#' @details List of Nuclease objects representing common restriction enzymes
#'     from REBASE database. 
#' @usage data(restrictionEnzymes, package="crisprBase")
"restrictionEnzymes"


#' SpCas9 CrisprNuclease object
#'
#' CrisprNuclease object for the wildtype Streptococcus pyogenes Cas9 (SpCas9)
#'     nuclease.
#' 
#' @format CrisprNuclease object.
#' 
#' @details The SpCas9 nuclease recognizes NGG PAM sequences. Spacer
#'     sequences must be located upstream of PAM sequences.
#' @usage data(SpCas9, package="crisprBase")
"SpCas9"




#' SaCas9 CrisprNuclease object
#'
#' CrisprNuclease object for the wildtype Staphylococcus aureus Cas9 (SaCas9)
#'     nuclease.
#' 
#' @format CrisprNuclease object.
#' 
#' @details The AsCas9 nuclease recognizes NNGRRT PAM sequences. Spacer
#'     sequences must be located upstream of PAM sequences. Editing weights 
#'     were obtained from \url{doi:10.1038/nature14299}.
#' 
#' @usage data(SaCas9, package="crisprBase")
"SaCas9"


#' SpGCas9 CrisprNuclease object
#'
#' CrisprNuclease object for the engineered Streptococcus pyogenes Cas9
#'     SpG nuclease.
#' 
#' @format CrisprNuclease object.
#' 
#' @details The SpGCas9 nuclease recognizes NGN PAM sequences. Spacer
#'     sequences must be located upstream of PAM sequences.
#' @usage data(SpGCas9, package="crisprBase")
"SpGCas9"


#' AsCas12a CrisprNuclease object
#'
#' CrisprNuclease object for the Wildtype Acidaminococcus Cas12a (AsCas12a)
#'     nuclease.
#' 
#' @format CrisprNuclease object.
#' @details The AsCas12a nuclease recognizes TTTV PAM sequences. Spacer
#'     sequences must be located downstream of PAM sequences.
#' @usage data(AsCas12a, package="crisprBase")
"AsCas12a"


 

#' enAsCas12a CrisprNuclease object
#'
#' CrisprNuclease object for the Enhanced Acidaminococcus Cas12a (AsCas12a)
#'     nuclease.
#' 
#' @format CrisprNuclease object.
#' @details The enAsCas12a nuclease recognizes an extended set of PAM sequences
#'     beyong the canonical TTTV sequence for AsCas12a. Spacer sequences must 
#'     be located downstream of PAM sequences.
#' @usage data(enAsCas12a, package="crisprBase")
"enAsCas12a"





#' MAD7 CrisprNuclease object
#'
#' CrisprNuclease object for the MAD7 nuclease (Cas12a-like nuclease)
#' 
#' @format CrisprNuclease object.
#' @details The MAD7 nuclease recognizes YTTV PAM sequences. Spacer
#'     sequences must be located downstream of PAM sequences.
#' @usage data(MAD7, package="crisprBase")
"MAD7"





#' CasRx CrisprNuclease object
#'
#' CrisprNuclease object for the Cas13d-NLS from Ruminococcus
#'     flavefaciens strain XPD3002 nuclease (RNase). 
#' 
#' @format CrisprNuclease object.
#' @details The CasRx nuclease was derived from Cas13d Ruminococcus
#'     flavefaciens string XPD3002. See \url{10.1016/j.cell.2018.02.033}.
#' @usage data(CasRx, package="crisprBase")
"CasRx"


#' Csm CrisprNuclease object
#'
#' CrisprNuclease object for the RNA-targeting
#'     Csm complex from Streptococcus thermophilus 
#' 
#' @format CrisprNuclease object.
#' @details The specific Csm complex is an RNA-targeting nuclease derived from 
#'     Streptococcus thermophilus. There is no preferred PAM sequences,
#'     and the default (optimal) spacer length is 32nt. 
#'     See \url{https://doi.org/10.1038/s41587-022-01649-9}.
#' @usage data(Csm, package="crisprBase")
"Csm"




#' BE4max BaseEditor object
#'
#' BaseEditor for the cytosine base editor CRISPR/Cas9 system
#'     BE4max. Editing weights were obtained from
#'     https://doi.org/10.1016/j.cell.2020.05.037
#' 
#' @format BaseEditor object.
#' @details  BaseEditor for the cytosine base editor
#'     CRISPR/Cas9 system BE4max. Editing weights were obtained from
#'     \url{https://doi.org/10.1016/j.cell.2020.05.037}.
#' @usage data(BE4max, package="crisprBase")
"BE4max"




