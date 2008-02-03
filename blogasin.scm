#!/usr/bin/env gosh
;; AWS on Gauche

(use srfi-11)
(use rfc.http)
(use sxml.ssax)
(use sxml.sxpath)
(use gauche.charconv)

(define (main args)
  (let* ((sxml (get-sxml-from-aws (cadr args)))
	 (item ((car-sxpath '(aws:ItemLookupResponse aws:Items aws:Item)) sxml)))
    (let ((img-list ((sxpath '(aws:MediumImage aws:URL)) item))
	  (detail (cadr ((car-sxpath '(aws:DetailPageURL)) item)))
	  (attr ((car-sxpath '(aws:ItemAttributes)) item)))
      (let ((authors (string-join (map cadr ((sxpath '(aws:Author)) attr)) "、"))
	    (title (cadr ((car-sxpath '(aws:Title)) attr)))
	    (label (cadr ((car-sxpath '(aws:Label)) attr)))
	    (img (if (null? img-list)
		     #f
		     (cadar img-list))))
	(print #`"= ,title")
	(when img
	  (print #`"((<\"img:,|img|\">))"))
	(print #`",|authors|『((<,|title||URL:,|detail|>))』（,|label|）")

	0
	))
    ))

(define (get-sxml-from-aws asin)
  (let-values (((status header body)
		(http-get "webservices.amazon.co.jp"
			  (string-append "/onca/xml"
					 "?Service=AWSECommerceService"
					 "&SubscriptionId=0D8NM7HNWSQBRZTMGY02"
					 "&AssociateTag=torusjp-22"
					 "&Operation=ItemLookup"
					 "&ResponseGroup=Medium"
					 "&ItemId=" asin))))
    (let* ((raw-in (open-input-string body))
	   (in (open-input-conversion-port raw-in 'utf-8)))
      (ssax:xml->sxml
       in
       (list
	(cons 'aws
	      "http://webservices.amazon.com/AWSECommerceService/2005-10-05"))))))

;; (*TOP*
;;  (@@ (*NAMESPACES*
;;       (aws http://webservices.amazon.com/AWSECommerceService/2005-10-05)))
;;  (*PI* xml version="1.0" encoding="UTF-8")
;;  (aws:ItemLookupResponse
;;   (aws:OperationRequest
;;    (aws:HTTPHeaders (aws:Header (@ (Name UserAgent))))
;;    (aws:RequestId 1H6MK4927J7EAVSJWF7G)
;;    (aws:Arguments
;;     (aws:Argument (@ (Value torusjp-22) (Name AssociateTag)))
;;     (aws:Argument (@ (Value 0D8NM7HNWSQBRZTMGY02) (Name SubscriptionId)))
;;     (aws:Argument (@ (Value Medium) (Name ResponseGroup)))
;;     (aws:Argument (@ (Value ItemLookup) (Name Operation)))
;;     (aws:Argument (@ (Value AWSECommerceService) (Name Service)))
;;     (aws:Argument (@ (Value 4894712571) (Name ItemId))))
;;    (aws:RequestProcessingTime 0.0509159564971924))
;;   (aws:Items
;;    (aws:Request (aws:IsValid True)
;; 		(aws:ItemLookupRequest (aws:ItemId 4894712571) (aws:ResponseGroup Medium)))
;;    (aws:Item (aws:ASIN 4894712571)
;; 	     (aws:DetailPageURL
;; 	      http://www.amazon.co.jp/exec/obidos/redirect?tag=torusjp-22%26link_code=xm2%26camp=2025%26creative=165953%26path=http://www.amazon.co.jp/gp/redirect.html%253fASIN=4894712571%2526tag=torusjp-22%2526lcode=xm2%2526cID=2025%2526ccmID=165953%2526location=/o/ASIN/4894712571%25253FSubscriptionId=0D8NM7HNWSQBRZTMGY02)
;; 	     (aws:SalesRank 60616)
;; 	     (aws:SmallImage
;; 	      (aws:URL http://images.amazon.com/images/P/4894712571.09._SCTHUMBZZZ_.jpg)
;; 	      (aws:Height (@ (Units pixels)) 60)
;; 	      (aws:Width (@ (Units pixels)) 46))
;; 	     (aws:MediumImage
;; 	      (aws:URL http://images.amazon.com/images/P/4894712571.09._SCMZZZZZZZ_.jpg)
;; 	      (aws:Height (@ (Units pixels)) 140)
;; 	      (aws:Width (@ (Units pixels)) 107))
;; 	     (aws:LargeImage
;; 	      (aws:URL http://images.amazon.com/images/P/4894712571.09._SCLZZZZZZZ_.jpg)
;; 	      (aws:Height (@ (Units pixels)) 475)
;; 	      (aws:Width (@ (Units pixels)) 362))
;; 	     (aws:ImageSets
;; 	      (aws:ImageSet
;; 	       (@ (Category primary))
;; 	       (aws:SmallImage
;; 		(aws:URL http://images.amazon.com/images/P/4894712571.09._SCTHUMBZZZ_.jpg)
;; 		(aws:Height (@ (Units pixels)) 60)
;; 		(aws:Width (@ (Units pixels)) 46))
;; 	       (aws:MediumImage
;; 		(aws:URL http://images.amazon.com/images/P/4894712571.09._SCMZZZZZZZ_.jpg)
;; 		(aws:Height (@ (Units pixels)) 140)
;; 		(aws:Width (@ (Units pixels)) 107))
;; 	       (aws:LargeImage
;; 		(aws:URL http://images.amazon.com/images/P/4894712571.09._SCLZZZZZZZ_.jpg)
;; 		(aws:Height (@ (Units pixels)) 475)
;; 		(aws:Width (@ (Units pixels)) 362))))
;; 	     (aws:ItemAttributes
;; 	      (aws:Author W.リチャード スティーヴンス)
;; 	      (aws:Binding 単行本)
;; 	      (aws:Creator (@ (Role 著)) W.リチャード スティーヴンス)
;; 	      (aws:Creator (@ (Role 原著)) W.Richard Stevens)
;; 	      (aws:Creator (@ (Role 翻訳)) 篠田 陽一)
;; 	      (aws:Edition 第2版)
;; 	      (aws:Label ピアソンエデュケーション)
;; 	      (aws:ListPrice (aws:Amount 5040) (aws:CurrencyCode JPY)
;; 			     (aws:FormattedPrice 〓 5,040))
;; 	      (aws:Manufacturer ピアソンエデュケーション)
;; 	      (aws:NumberOfPages 544)
;; 	      (aws:PackageDimensions (aws:Length (@ (Units cm)) 24))
;; 	      (aws:ProductGroup Book)
;; 	      (aws:PublicationDate 2000-08)
;; 	      (aws:Publisher ピアソンエデュケーション)
;; 	      (aws:Studio ピアソンエデュケーション)
;; 	      (aws:Title UNIXネットワークプログラミング〈Vol.2〉IPC:プロセス間通信))
;; 	     (aws:OfferSummary
;; 	      (aws:LowestNewPrice
;; 	       (aws:Amount 5040) (aws:CurrencyCode JPY) (aws:FormattedPrice 〓 5,040))
;; 	      (aws:TotalNew 1)
;; 	      (aws:TotalUsed 0)
;; 	      (aws:TotalCollectible 0)
;; 	      (aws:TotalRefurbished 0))))
;;   ))
