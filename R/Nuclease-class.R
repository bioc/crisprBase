#' An S4 class to represent a nuclease.
#' 
#' @slot name Name of the nuclease.
#' @slot motifs DNAStringSet of recognition sequence motifs
#'           written from 5' to 3'.
#' @slot cutSites Matrix with 2 rows (+ and - strand, respectively)
#'     specifying the cleavage coordinates relative to the first
#'     nucleotide of the motif sequence. Each column corresponds
#'     to a motif specified in the \code{motifs} slot. 
#' @slot weights Optional numeric vector specifying relative weights
#'           for the motifs corresponding to cleavage probabilities. 
#' @slot info Optional string providing a description of the nuclease.
#' 
#' @seealso See the \linkS4class{CrisprNuclease} for CRISPR-specific nucleases.
#' 
#' @section Constructors:
#'     Use the constructor \code{link{Nuclease}} to create a Nuclease object.
#' 
#' @section Accessors:
#' \describe{
#'     \item{\code{name}:}{To get the name of the nuclease.} 
#'     \item{\code{motifs}:}{To get the recognition mofif
#'          nucleotide sequences.}
#' }
#' 
#' @examples
#' EcoRI <- Nuclease("EcoRI",
#'                   motifs=c("G^AATTC"),
#'                   info="EcoRI restriction enzyme")
#' 
#' 
#' @export
#' @importFrom Biostrings DNAStringSet
setClass("Nuclease", 
    slots = c(
        name = "character", 
        motifs = "DNAStringSet",
        cutSites = "matrix",
        weights = "numeric", 
        info = "character"),
    prototype = list(
        name = NA_character_,
        motifs = NULL,
        cutSites = NULL,
        weights = NA_real_,
        info = NA_character_)
)





setValidity("Nuclease", function(object){
    out <- TRUE
    if (length(object@name)!=1){
       out <- "@name must be of length 1"
    } 
    if (length(object@info)!=1){
       out <- "@info must be of length 1"
    } 

    if (length(object@weights)>1){
        if (length(object@weights) != length(object@motifs)){
            out <- "object@weights and object@motifs must be of the same length"
        } 
    } 

    if (ncol(object@cutSites) != length(object@motifs)){
        out <- "Number of columns in object@cutSites must be equal to the length of object@motifs"
    }
    if (nrow(object@cutSites)!=2){
        out <- "Number of rows in object@cutSites must be equal to 2"
    }

    return(out)
})



#' @describeIn Nuclease Create a \linkS4class{Nuclease} object
#' @param name Name of the nuclease.
#' @param motifs Character vector of recognition sequence motifs
#'           written from 5' to 3' written in Rebase convention.
#'           If the point of cleavage has been determined, the
#'           precise site is marked with ^. Only letters in the
#'           IUPAC code are accepted. For nucleases that cleave
#'           away from their recognition sequence, the cleavage
#'           sites are indicated in parentheses. See details for
#'           more information. 
#' @param cutSites Matrix with 2 rows (+ and - strand, respectively)
#'     specifying the cleavage coordinates relative to the first
#'     nucleotide of the motif sequence. Each column corresponds
#'     to a motif specified in the \code{motifs} slot. 
#' @param weights Optional numeric vector specifying relative weights
#'           for the recognition motifs to specify cleavage probabilities. 
#' @param info Optional string providing a description of the nuclease.
#' @export
Nuclease <- function(name,
    motifs = NULL,
    cutSites = NULL,
    weights = rep(1, length(motifs)),
    info = NA_character_
){

    name    <- as.character(name)
    weights <- as.numeric(weights)
    info <- as.character(info)

    if (is(motifs, "DNAStringSet")){    
        if (is.null(cutSites)){
            stop("When 'motifs' is provided as a DNAStringset, ",
                 "'cutSites' must be provided. ")
        }
        sequences <- motifs
    } else if (is.character(motifs) & !is.null(cutSites)){
        .checkDNAAlphabet(motifs)
        sequences <- DNAStringSet(motifs)
    } else if (is.character(motifs) & is.null(cutSites)){
        .checkRebaseMotifs(motifs)
        sequences <- .extractSequencesFromRebaseMotifs(motifs)
        cutSites  <- .extractCutSitesFromRebaseMotifs(motifs)
    } else {
        stop("'motifs' must be either a character vector or a ",
             "DNAStringSet.")
    }
    
    new("Nuclease",
        name=name,
        motifs=sequences,
        cutSites=cutSites,
        weights=weights,
        info=info)
}




#' @importFrom stringr str_match
.checkRebaseMotif <- function(rebaseMotif){
    choices <- c(names(Biostrings::IUPAC_CODE_MAP),
                 "^", "(", ")",
                 0:9,
                 "-", "/")
    symbols <- strsplit(rebaseMotif, split="")[[1]]
    if(!all(symbols %in% choices)){
        offenders <- unique(setdiff(symbols, choices))
        offenders <- paste0(offenders, collapse=",")
        stop("The following characters are not allowed: ",
             offenders)
    }

    #Checking if Rebase motif follows expected pattern:
    pattern="(\\([0-9]+/[0-9]+\\))?([A-Z]*\\^?[A-Z]*)(\\([0-9]+/[0-9]+\\))?"
    if (str_match(rebaseMotif, pattern)[1]!=rebaseMotif){
        stop("Motif does not follow the notation needed for ",
             "a recognition site. See details.")
    }

    if (.isCutUpstream(rebaseMotif) & .isCutDownstream(rebaseMotif)){
        stop("For nucleases cleaving outside of the recognition site, 
             only one set of parentheses should be provided. 
             Example: (9/10)ACCTG or ACCTG(9/10) are valid, 
             but not (9/10)ACCTG(9/10).")
    }
    if ((.isCutUpstream(rebaseMotif)|
         .isCutDownstream(rebaseMotif)) &
         .isCutWithin(rebaseMotif)){
        stop("Concurrent cleavage outside of the recognition site and
             within the recognition sequence are not supported at the moment.
             Example: (9/10)ACCTG is valid, but (9/10)AC^CTG is invalid.")
    }
}

.checkRebaseMotifs <- function(rebaseMotifs){
    x=lapply(rebaseMotifs, .checkRebaseMotif)
}


.isCutUpstream <- function(rebaseMotif){
    grepl("^\\([0-9]+/[0-9]+\\)", rebaseMotif)
}

.isCutDownstream <- function(rebaseMotif){
    grepl("\\([0-9]+/[0-9]+\\)$", rebaseMotif)
}

.isCutWithin <- function(rebaseMotif){
    grepl("\\^", rebaseMotif)
}

.isCutNotSpecified <- function(rebaseMotif){
    !.isCutUpstream(rebaseMotif) & 
    !.isCutDownstream(rebaseMotif) &
    !.isCutWithin(rebaseMotif) 
}



#' @importFrom stringr str_match
.extractSequencesFromRebaseMotifs <- function(rebaseMotifs){
    #pattern <- "([A-Z]+\\^?[A-Z]+)"
    pattern <- "([A-Z]+)"
    seqs <- vapply(rebaseMotifs, function(xx){
        xx <- gsub("\\^", "", xx)
        return(str_match(xx, pattern)[1])
    }, FUN.VALUE="a")
    names(seqs) <- NULL
    seqs <- DNAStringSet(seqs)
    return(seqs)
}


.extractCutSitesFromRebaseMotifs <- function(rebaseMotifs){
    cutSites <- lapply(rebaseMotifs, .getCutSites)
    cutSites <- do.call("cbind", cutSites)
    cutSites <- as.matrix(cutSites)
    rownames(cutSites) <- c("fwd", "rev")
    motifs <- .extractSequencesFromRebaseMotifs(rebaseMotifs)
    colnames(cutSites) <- as.character(motifs)
    return(cutSites)
}




.getCutSites <- function(rebaseMotif){
    if (.isCutWithin(rebaseMotif)){
        cutSites <- .getCutSites_within(rebaseMotif)
    } else if (.isCutUpstream(rebaseMotif)){
        cutSites <- .getCutSites_upstream(rebaseMotif)
    } else if (.isCutDownstream(rebaseMotif)){
        cutSites <- .getCutSites_downstream(rebaseMotif)
    } else if (.isCutNotSpecified(rebaseMotif)){
        cutSites <- .getCutSites_unspecified(rebaseMotif)
    }
    return(cutSites)
}


.getCutSites_unspecified <- function(rebaseMotif){
    out <- c(fwd=NA, rev=NA)
    return(out)
}

.getCutSites_upstream <- function(rebaseMotif){
    stopifnot(.isCutUpstream(rebaseMotif))
    pattern <- "^\\([0-9]+/[0-9]+\\)"
    pos <- regexpr(pattern, rebaseMotif)
    cut_info <- substr(rebaseMotif, pos, pos+attr(pos, "match.length")-1)
    cut_info <- gsub("\\(|\\)", "", cut_info)
    cut_pos <- as.integer(strsplit(cut_info, split="/")[[1]][[1]])
    cut_neg <- as.integer(strsplit(cut_info, split="/")[[1]][[2]])
    out <- c(fwd=-cut_pos, rev=-cut_neg)
    return(out)
}

.getCutSites_downstream <- function(rebaseMotif){
    seq <- .extractSequencesFromRebaseMotifs(rebaseMotif)
    motifLength <- BiocGenerics::width(seq)
    stopifnot(.isCutDownstream(rebaseMotif))
    pattern <- "\\([0-9]+/[0-9]+\\)$"
    pos <- regexpr(pattern, rebaseMotif)
    cut_info <- substr(rebaseMotif,
                       pos,
                       pos+attr(pos, "match.length")-1)
    cut_info <- gsub("\\(|\\)", "", cut_info)
    cut_pos <- as.integer(strsplit(cut_info, split="/")[[1]][[1]])
    cut_neg <- as.integer(strsplit(cut_info, split="/")[[1]][[2]])
    out <- c(fwd=cut_pos + motifLength,
             rev=cut_neg + motifLength)
    return(out)
}


.getCutSites_within <- function(rebaseMotif){
    seq <- .extractSequencesFromRebaseMotifs(rebaseMotif)
    motifLength <- BiocGenerics::width(seq)
    stopifnot(.isCutWithin(rebaseMotif))
    chars <- strsplit(rebaseMotif, split="")[[1]]
    pos <- which(chars=="^")
    cut_pos <- pos-1
    cut_neg <- motifLength - cut_pos
    out <- c(fwd=cut_pos, rev=cut_neg)
    return(out)
}






# Functions to write:
#.validateCutSites()








#' @rdname Nuclease-class
#' @param object \linkS4class{Nuclease} object.
setMethod("show", "Nuclease", function(object){
    cat(paste0("Class: ", is(object)[[1]]), "\n",
      "  Name: ", object@name, "\n",
      "  Info: ", object@info, "\n",
      "  Motifs: ", .printVectorNicely(object@motifs), "\n",
      "  Weights: ", .printVectorNicely(object@weights), "\n",
      sep = "")
})


#' @rdname Nuclease-class
#' @export
setMethod("name", "Nuclease", 
    function(object){
    return(object@name)
})

#' @rdname Nuclease-class
#' @param value New value to pass to the setter functions.
#' @export
setMethod("name<-", "Nuclease", 
    function(object, value){
    object@name <- as.character(value)
    return(object)
})

#' @rdname Nuclease-class
#' @export
setMethod("info<-", "Nuclease", 
    function(object, value){
    object@info <- as.character(value)
    return(object)
})

#' @rdname Nuclease-class
#' @export
setMethod("weights", "Nuclease", 
    function(object,
             expand=FALSE
){
    ws <- object@weights
    names(ws) <- motifs(object)
    if (expand){
        motifs <- .expandMotifs(names(ws))
        ws <- ws[names(motifs)]
    }
    return(ws)
})

#' @rdname Nuclease-class
#' @export
setMethod("weights<-", "Nuclease", 
    function(object, value){
    seqs <- object@motifs
    if (is.null(value)){
        object@motifs <- NA
    } else if (length(value)==1){
        object@motifs <- value
    } else if (length(value)==length(seqs)){
        object@motifs <- value
    } 
    object@weights <- value
    return(object)
})



#' @rdname Nuclease-class
#' @param primary Should only the motif with the highest weight be returned?
#'     FALSE by default. Only relevant if weights are stored in the 
#'     \linkS4class{Nuclease} object.
#' @param expand Should sequences be expanded to only contain ATCG nucleotides?
#'     FALSE by default.
#' @param strand Strand to allow reverse complementation of the motif.
#'     "+" by default. 
#' @param as.character Should the motif sequences be returned as a 
#'     character vector? FALSE by default.
#' @importFrom Biostrings reverseComplement
#' @export
setMethod("motifs", "Nuclease", 
    function(object,
             primary=FALSE,
             strand=c("+", "-"),
             expand=FALSE,
             as.character=FALSE
){
    strand <- match.arg(strand)
    motifs  <- object@motifs
    weights <- object@weights

    if (length(weights)>1 & primary){
        w <- max(weights, na.rm=TRUE)
        motifs <- motifs[which(weights==w)]
    }

    if (strand=="-"){
        motifs <- reverseComplement(motifs)
    }
    if (expand){
        motifs <- .expandMotifs(motifs)
    }
    if (as.character){
        motifs <- as.character(motifs)
    }
    return(motifs)
})





#' @rdname Nuclease-class
#' @param object \linkS4class{Nuclease} object.
#' @importFrom BiocGenerics width
#' @export
setMethod("motifLength",
          "Nuclease",function(object) {
    seqs <- motifs(object, primary=TRUE)[1]
    names(seqs) <- NULL
    return(BiocGenerics::width(seqs))
})






.expandMotifs <- function(motifs){
    if (is.null(motifs)){
        return(NULL)
    }
    motifs <- as.character(motifs)
    if (length(motifs)==1){
        if (is.na(motifs)){
            return(character(0))    
        }
    }
    nucs <- strsplit(motifs, split="")
   
    nucs <- lapply(nucs, function(x){
        x <- strsplit(Biostrings::IUPAC_CODE_MAP[x], split="")
        x <- expand.grid(x)
        x <- apply(x, 1, paste0, collapse="")
        return(x)
    })
    for (i in seq_along(nucs)){
        names(nucs[[i]]) <- rep(motifs[i], length(nucs[[i]]))
    }
    nucs <- unlist(nucs)
    nucs <- DNAStringSet(nucs)
    return(nucs)
}






#' @rdname Nuclease-class
#' @param middle For staggered cuts, should the middle point between
#'     the cut on the forward strand and the cut on the reverse strand
#'     be considered as the cut site? FALSE by default.
#' @param combine Should only unique values be considered?
#'     TRUE by default. 
#' @export
setMethod("cutSites", "Nuclease", 
    function(object,
             strand=c("+", "-"),
             combine=TRUE,
             middle=FALSE
){
    sites  <- object@cutSites
    motifs <- object@motifs
    strand <- match.arg(strand)

    if (middle){
        sites <- floor((sites[1,]+sites[2,])/2)
    } else if (strand=="+"){
        sites <- sites["fwd",]
    } else if (strand=="-"){
        sites <- sites["rev",]
    }
    
    names(sites) <- motifs
    if (combine){
        choices <- unique(sites)
        if (length(choices)==1){
            sites <- choices
            names(sites) <- NULL
        }
    }
    return(sites)
})





