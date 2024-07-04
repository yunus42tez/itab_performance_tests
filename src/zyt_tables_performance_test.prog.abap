*&---------------------------------------------------------------------*
*& Report ZYT_TABLES_PERFORMANCE_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zyt_tables_performance_test.

TABLES: sflight.

DATA: lv_time   TYPE p DECIMALS 2,
      lv_time1  TYPE p DECIMALS 2,
      lv_time2  TYPE p DECIMALS 2,
      lv_connid TYPE i.

* Öncelikle standart, sorted ve hashed tablolarını tanımladık.

" Standart Tablo Tanımlaması
DATA: lt_standart_flights TYPE TABLE OF sflight.
DATA: lt_standart_flights2 TYPE STANDARD TABLE OF sflight.
DATA: lt_standart_flights3 TYPE STANDARD TABLE OF sflight.

" Sorted Tablo Tanımlaması
DATA: lt_sorted_flights TYPE SORTED TABLE OF sflight
WITH UNIQUE KEY carrid connid fldate.
DATA: lt_sorted_flights2 TYPE SORTED TABLE OF sflight
WITH NON-UNIQUE KEY carrid connid.

" Hashed Tablo Tanımlaması
DATA: lt_hashed_flights TYPE HASHED TABLE OF sflight
WITH UNIQUE KEY carrid connid fldate.

DATA: ls_sflight           TYPE sflight,
      ls_standard_flights3 TYPE sflight.

***** Sonrasında tanımladığımız tablolara ‘INSERT’ komutu kullanarak data ekledik ve sürelerini ölçerek hangi tablo tipinin daha hızlı olduğunu öğrendik.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  ls_sflight = VALUE #( carrid = 'THY'
  connid = lv_connid
  fldate = '01012024' ).
  INSERT ls_sflight INTO TABLE lt_standart_flights.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Insert Standart Table:', 25 lv_time, 'ms'.

******************************

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  ls_sflight = VALUE #( carrid = 'THY'
  connid = lv_connid
  fldate = '01012024' ).
  INSERT ls_sflight INTO TABLE lt_sorted_flights.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Insert Sorted Table:', 25 lv_time, 'ms'.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  ls_sflight = VALUE #( carrid = 'THY'
  connid = lv_connid
  fldate = '01012024' ).
  INSERT ls_sflight INTO TABLE lt_hashed_flights.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Insert Hashed Table:', 25 lv_time, 'ms'.

******************************


****** sonrasında ‘read’ komutunu with key ve binary search yardımıyla tablomuzdan satır bazlı olarak dataya hangi hızlarda ulaşabildiğimizi öğrendik.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_standart_flights INTO DATA(ls_standart_flight3) WITH KEY connid = lv_connid.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Key Standart Table:', 50 lv_time, 'ms'.

SORT lt_standart_flights BY connid.

DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_standart_flights INTO DATA(ls_standart_flight2) WITH KEY connid = lv_connid BINARY SEARCH.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Key Binary Search Standart Table:', 50 lv_time, 'ms'.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_sorted_flights INTO DATA(ls_sorted_flight) WITH KEY connid = lv_connid.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Key Sorted Table:', 50 lv_time, 'ms'.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_hashed_flights INTO DATA(ls_hashed_flight) WITH KEY connid = lv_connid.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Key Hashed Table:', 50 lv_time, 'ms'.

****************************************************************


**** Son olarak ise yine ‘READ’ komutunu index yardımı ile kullandık fakat burada hashed tabloda index arama yapamadığımız için kullanmadık.
**** Bu yüzden standart ve sorted tablolarında hangisinin daha hızlı olduğunu öğrendik.

GET RUN TIME FIELD lv_time1.
DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_standart_flights INTO ls_standart_flight3 INDEX 250.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Index Standart Table:', 50 lv_time, 'ms'.

DO 500 TIMES.
  lv_connid = lv_connid + 1.
  READ TABLE lt_sorted_flights INTO DATA(ls_sorted_flight3) INDEX 250.
ENDDO.

GET RUN TIME FIELD lv_time2.
lv_time = ( lv_time2 - lv_time1 ) / 500.
WRITE: / 'Read With Index Sorted Table:', 50 lv_time, 'ms'.



************** BU KISIMDAN SONRASI YORUM SATIRINDA OLMALI


** Select yapılarında '*' kullanmaktan kaçınmalıyız. Bunun yerine ihtiyacımız olan
** alanları * yerine yazarsak daha hızlı bir performansla kullanımış oluruz.
*
*" Kötü Performans
*SELECT *
*FROM mara
*INTO TABLE @DATA(lt_mara).
*
*" İyi Performans
*SELECT matnr,
*       mtart,
*       maktl,
*       meins
*FROM mara
*INTO TABLE @DATA(lt_mara2).
*
** Tek satır data çekmek istediğimizde select single yapısını kullanmalıyız.
*
*SELECT SINGLE carrid,
*              connid,
*              fdate,
*              price,
*              currency
*FROM sflight
*WHERE carrid EQ 'AA'
*  AND connid EQ '26'
*  AND fdate EQ '20220914'
*INTO @DATA(ls_sflight).
*
** Select yapılarında 'INTO CORRESPONDING' ifadesini kullanmalıyız.
** Select sorgusundaki alan sıralamasıyla internal tablomuzdaki alan sıralaması
** aynı olmalıdır.
*
*SELECT seatsmax,
*       connid,
*       seatsocc,
*       carrid,
*       fdate
*FROM sflight
*INTO CORRESPONDING FIELDS OF TABLE @lt_data.
*
*SELECT carrid,
*       connid,
*       fdate,
*       seatsmax,
*       seatsocc
*FROM sflight
*INTO TABLE @lt_data.
*
**** Loop Döngüsü
***
***Loop döngüsü içerisinde select atmak çok büyük performans kaybı yaşatır.
***Çünkü döngüye her girdiğinde veritabanına gidip verileri internal tabloya getiriyor.
***Bunun yerine select sorgusunu loop döngüsüne gelmeden önce tamamlayıp,
***loop döngüsüne girdiğinde read komutu ile değişiklik yapmak istediğimiz dataya ulaşmalıyız.
*
*SELECT carrid,
*       connid,
*       fldate,
*       seatsmax,
*       seatsocc
*  FROM sflight
* WHERE carrid EQ 'AA'
*   AND connid EQ '26'
* INTO TABLE @lt_sflight.
*
*SORT lt_sflight BY carrid connid.
*LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*
*  READ TABLE lt_sflight ASSIGNING FIELD-SYMBOL(<fs_sflight>) WITH KEY fldate = '20220914' BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    ENDIF.
*  ENDLOOP.
*ENDLOOP.
*
****Loop döngüsünde dönen internal tablomuzdaki datayı var ise koşula göre loop döngüsüne girmelidir.
*
*LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>) WHERE ( connid > 20 and connid <= 30 ).
*  ENDLOOP.
*
****İç içe döngülerde performansı arttırmak için Parallel Cursor yöntemini kullanmalıyız.
*
*
*DATA: lt_vbak TYPE i.
*
*SELECT vbeln
*  FROM vbak
*  INTO TABLE @DATA(lt_vbak)
*  UP TO 1000 ROWS.
*
*SELECT vbeln
*  FROM vbap
*  INTO TABLE @DATA(lt_vbap)
*  UP TO 1000 ROWS.
*
*** İki tablonun da sortlanması gerekiyor key value'lara göre.
*SORT lt_vbak BY vbeln.
*SORT lt_vbap BY vbeln.
*
*LOOP AT lt_vbak ASSIGNING FIELD-SYMBOL(<fs_vbak>).
*
*  * İkinci tablonun keylerini okuyoruz. Sadece index alacağımız için TRANSPORTING NO FIELDS kullandık.
*  READ TABLE lt_vbap TRANSPORTING NO FIELDS WITH KEY vbeln = <fs_vbak>-vbeln BINARY SEARCH.
*  IF sy-subrc EQ 0.
*
*    lv_tabix = sy-tabix.
*    LOOP AT lt_vbap ASSIGNING FIELD-SYMBOL(<fs_vbap>) FROM lv_tabix.
*      IF <fs_vbap>-vbeln EQ <fs_vbak>-vbeln.
*        * Koşul sağlanıyorsa çalıştırmayı bu alanda yapıyoruz.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*ENDLOOP.
*

****Read Komutu
****
****Internal tablodan veri okurken okuyacağımız alana göre sıralayıp read komutunu 'BINARY SEARCH' yardımıyla okumalıyız.
****Sıralama yapılması önemlidir.
*
*SELECT carrid,
*       connid,
*       fldate,
*       seatsmax,
*       seatsocc
*  FROM sflight
* WHERE carrid EQ 'AA'
*   AND connid EQ '26'
* INTO TABLE @lt_sflight.
*
*SORT lt_sflight BY carrid connid.
*READ TABLE lt_sflight ASSIGNING FIELD-SYMBOL(<fs_sflight>) WITH KEY fldate = '20220914' BINARY SEARCH.
