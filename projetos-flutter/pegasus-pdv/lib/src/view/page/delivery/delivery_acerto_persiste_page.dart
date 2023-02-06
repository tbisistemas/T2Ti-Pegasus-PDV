/*
Title: T2Ti ERP 3.0                                                                
Description: PersistePage relacionada à tabela [DELIVERY_ACERTO] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2021 T2Ti.COM                                          
                                                                                
Permission is hereby granted, free of charge, to any person                     
obtaining a copy of this software and associated documentation                  
files (the "Software"), to deal in the Software without                         
restriction, including without limitation the rights to use,                    
copy, modify, merge, publish, distribute, sublicense, and/or sell               
copies of the Software, and to permit persons to whom the                       
Software is furnished to do so, subject to the following                        
conditions:                                                                     
                                                                                
The above copyright notice and this permission notice shall be                  
included in all copies or substantial portions of the Software.                 
                                                                                
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,                 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES                 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                        
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT                     
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,                    
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING                    
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR                   
OTHER DEALINGS IN THE SOFTWARE.                                                 
                                                                                
       The author may be contacted at:                                          
           t2ti.com@gmail.com                                                   
                                                                                
@author Albert Eije (alberteije@gmail.com)                    
@version 1.0.0
*******************************************************************************/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:pegasus_pdv/src/database/database_classes.dart';

import 'package:pegasus_pdv/src/infra/infra.dart';
import 'package:pegasus_pdv/src/infra/atalhos_desktop_web.dart';

import 'package:pegasus_pdv/src/view/shared/view_util_lib.dart';
import 'package:pegasus_pdv/src/view/shared/caixas_de_dialogo.dart';
import 'package:pegasus_pdv/src/view/shared/botoes.dart';
import 'package:pegasus_pdv/src/view/shared/widgets_input.dart';

import 'package:extended_masked_text/extended_masked_text.dart';

class DeliveryAcertoPersistePage extends StatefulWidget {
  final DeliveryAcertoMontado? deliveryAcertoMontado;
  final String? title;

  const DeliveryAcertoPersistePage({Key? key, this.deliveryAcertoMontado, this.title})
      : super(key: key);

  @override
  DeliveryAcertoPersistePageState createState() => DeliveryAcertoPersistePageState();
}

class DeliveryAcertoPersistePageState extends State<DeliveryAcertoPersistePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _formFoiAlterado = false;

  Map<LogicalKeySet, Intent>? _shortcutMap; 
  Map<Type, Action<Intent>>? _actionMap;
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    bootstrapGridParameters(
      gutterSize: Constantes.flutterBootstrapGutterSize,
    );

    _shortcutMap = getAtalhosPersistePage();

    _actionMap = <Type, Action<Intent>>{
      AtalhoTelaIntent: CallbackAction<AtalhoTelaIntent>(
        onInvoke: _tratarAcoesAtalhos,
      ),
    };
    _foco.requestFocus();
  }

  void _tratarAcoesAtalhos(AtalhoTelaIntent intent) {
    switch (intent.type) {
      case AtalhoTelaType.excluir:
        _excluir();
        break;
      case AtalhoTelaType.salvar:
        _salvar();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {	
    final horaAcertoController = MaskedTextController(
      mask: Constantes.mascaraHORA,
      text: widget.deliveryAcertoMontado!.deliveryAcerto?.horaAcerto ?? '',
    );
    final valorRecebidoController = MoneyMaskedTextController(precision: Constantes.decimaisValor, initialValue: widget.deliveryAcertoMontado!.deliveryAcerto?.valorRecebido ?? 0);
    final valorPagoEntregadorController = MoneyMaskedTextController(precision: Constantes.decimaisValor, initialValue: widget.deliveryAcertoMontado!.deliveryAcerto?.valorPagoEntregador ?? 0);
	
    return FocusableActionDetector(
      actions: _actionMap,
      shortcuts: _shortcutMap,
      child: Focus(
        autofocus: true,
        child: Scaffold(drawerDragStartBehavior: DragStartBehavior.down,
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(widget.title!), 
            actions: getBotoesAppBarPersistePage(context: context, salvar: _salvar,),
          ),      
          body: SafeArea(
            top: false,
            bottom: false,
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate,
              onWillPop: _avisarUsuarioFormAlterado,
              child: Scrollbar(
                child: SingleChildScrollView(
                  dragStartBehavior: DragStartBehavior.down,
                  child: BootstrapContainer(
                    fluid: true,
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: Biblioteca.isTelaPequena(context) == true ? ViewUtilLib.paddingBootstrapContainerTelaPequena : ViewUtilLib.paddingBootstrapContainerTelaGrande,
                    children: <Widget>[
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: InputDecorator(
                              decoration: getInputDecoration(
                                'Informe a Data Acerto',
                                'Data Acerto',
                                true),
                              isEmpty: widget.deliveryAcertoMontado!.deliveryAcerto!.dataAcerto == null,
                              child: DatePickerItem(
                                mascara: 'dd/MM/yyyy',
                                dateTime: widget.deliveryAcertoMontado!.deliveryAcerto!.dataAcerto,
                                firstDate: DateTime.parse('1900-01-01'),
                                lastDate: DateTime.now(),
                                onChanged: (DateTime? value) {
                                    _formFoiAlterado = true;
                                    setState(() {
                                      widget.deliveryAcertoMontado!.deliveryAcerto = widget.deliveryAcertoMontado!.deliveryAcerto!.copyWith(dataAcerto: value);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: horaAcertoController,
                              decoration: getInputDecoration(
                                'Informe a Hora do Acerto',
                                'Hora do Acerto',
                                false),
                              onSaved: (String? value) {
                              },
                              validator: ValidaCampoFormulario.validarHORA,
                              onChanged: (text) {
                                widget.deliveryAcertoMontado!.deliveryAcerto = widget.deliveryAcertoMontado!.deliveryAcerto!.copyWith(horaAcerto: text);
                                _formFoiAlterado = true;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              controller: valorRecebidoController,
                              decoration: getInputDecoration(
                                'Informe o Valor Recebido',
                                'Valor Recebido',
                                false),
                              onSaved: (String? value) {
                              },
                              onChanged: (text) {
                                widget.deliveryAcertoMontado!.deliveryAcerto = widget.deliveryAcertoMontado!.deliveryAcerto!.copyWith(valorRecebido: valorRecebidoController.numberValue);
                                _formFoiAlterado = true;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              controller: valorPagoEntregadorController,
                              decoration: getInputDecoration(
                                'Informe o Valor Pago',
                                'Valor Pago',
                                false),
                              onSaved: (String? value) {
                              },
                              onChanged: (text) {
                                widget.deliveryAcertoMontado!.deliveryAcerto = widget.deliveryAcertoMontado!.deliveryAcerto!.copyWith(valorPagoEntregador: valorPagoEntregadorController.numberValue);
                                _formFoiAlterado = true;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: TextFormField(
                              maxLength: 1000,
                              maxLines: 3,
                              initialValue: widget.deliveryAcertoMontado!.deliveryAcerto?.observacao ?? '',
                              decoration: getInputDecoration(
                                'Observações Gerais',
                                'Observação',
                                false),
                              onSaved: (String? value) {
                              },
                              onChanged: (text) {
                                widget.deliveryAcertoMontado!.deliveryAcerto = widget.deliveryAcertoMontado!.deliveryAcerto!.copyWith(observacao: text);
                                _formFoiAlterado = true;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                      BootstrapRow(
                        height: 60,
                        children: <BootstrapCol>[
                          BootstrapCol(
                            sizes: 'col-12',
                            child: 
                              Text(
                                '* indica que o campo é obrigatório',
                                style: Theme.of(context).textTheme.caption,
                              ),								
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white,),
                    ],        
                  ),
                ),
              ),			  
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidate = AutovalidateMode.always;
      showInSnackBar(Constantes.mensagemCorrijaErrosFormSalvar, context);
    } else {
      gerarDialogBoxConfirmacao(context, Constantes.perguntaSalvarAlteracoes, () {
        form.save();
        Sessao.db.deliveryAcertoDao.atualizar(widget.deliveryAcertoMontado!);
        Navigator.of(context).pop();
        showInSnackBar("Registro atualizado com sucesso!", context, corFundo: Colors.green);
      });
    }
  }

  Future<bool> _avisarUsuarioFormAlterado() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !_formFoiAlterado) {
      return true;
    } else {
      await (gerarDialogBoxFormAlterado(context));
      return false;
    }
  }
  
  void _excluir() {
    // gerarDialogBoxExclusao(context, () async {
	  // await Sessao.db.deliveryAcertoDao.excluir(deliveryAcerto!);
    //   Navigator.of(context).pop();
    //   showInSnackBar("Registro excluído com sucesso!", context, corFundo: Colors.green);
    // });
  }  
}